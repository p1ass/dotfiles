import type { EngineInterface, Register } from 'claude-code'

const SOURCE = 'custom:claude-mod'
const LIVE_AGENT_STATUSES = new Set(['pending', 'running'])
const APPROVAL_NOTIFICATIONS = new Set(['permission_prompt', 'elicitation_dialog'])
const EMPTY_TOKENS = { cc: '' }

type Tokens = Record<keyof typeof EMPTY_TOKENS, string>

const bridge = {
  pane: undefined as string | undefined,
  seq: 0,
  queue: Promise.resolve() as Promise<unknown>,
  isAwaitingApproval: false,
  sent: new Map<string, string>(),
}

async function send($: EngineInterface, tokens: Tokens) {
  const { pane, sent } = bridge
  if (pane === undefined) return
  const changed = Object.entries(tokens).filter(([name, value]) => sent.get(name) !== value)
  if (changed.length === 0) return
  for (const [name, value] of changed) sent.set(name, value)

  // herdr ignores a seq at or below the last accepted one, and a reload resets this module's counter.
  bridge.seq = Math.max(bridge.seq + 1, (await $.clock.now()) * 1000)
  const argv = ['herdr', 'pane', 'report-metadata', pane, '--source', SOURCE, '--seq', String(bridge.seq)]
  for (const [name, value] of changed) argv.push('--token', `${name}=${value}`)

  bridge.queue = bridge.queue.then(() => $.process.run(argv, { timeoutMs: 5000 })).catch(() => undefined)
  await bridge.queue
}

async function refresh($: EngineInterface, endingAgentId?: string) {
  if (bridge.pane === undefined) return
  const agents = await $.agent.list()
  const liveAgents = agents.filter(a => a.id !== endingAgentId && LIVE_AGENT_STATUSES.has(a.status)).length

  await send($, {
    cc: bridge.isAwaitingApproval ? 'needs approval' : liveAgents > 0 ? `${liveAgents} agents` : '',
  })
}

async function setApproval($: EngineInterface, isWaiting: boolean) {
  if (bridge.isAwaitingApproval === isWaiting) return
  bridge.isAwaitingApproval = isWaiting
  await refresh($)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    const isHerdr = (await $.env.get('HERDR_ENV')) === '1'
    bridge.pane = isHerdr ? await $.env.get('HERDR_PANE_ID') : undefined
    bridge.sent.clear()
    await refresh($)
    return next(e)
  })

  on('turn.start', async ($, e, next) => {
    const started = await next(e)
    if (e.agentId === undefined) bridge.isAwaitingApproval = false
    await refresh($)
    return started
  })

  on('turn.complete', async ($, e, next) => {
    const completed = await next(e)
    if (e.agentId === undefined) bridge.isAwaitingApproval = false
    await refresh($, e.agentId)
    return completed
  })

  on('classic.Notification', async ($, e, next) => {
    if (APPROVAL_NOTIFICATIONS.has(e.notification_type)) await setApproval($, true)
    return next(e)
  })

  on('tool.call', async ($, e, next) => {
    if (e.tool === 'AskUserQuestion') await setApproval($, true)
    const result = await next(e)
    await setApproval($, false)
    return result
  })

  on('session.end', async ($, e, next) => {
    await send($, EMPTY_TOKENS)
    return next(e)
  })
}
