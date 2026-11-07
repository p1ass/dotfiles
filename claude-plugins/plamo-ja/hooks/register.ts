import { atom, memberOf, read, update } from 'claude-code'
import type { EngineInterface, Register } from 'claude-code'

import type { Translation } from '../types'

const isEnabled = atom({ plugin: 'plamo-ja', key: 'isEnabled' } as const, true)
const translations = atom({ plugin: 'plamo-ja', key: 'translations' } as const, null)

const STOP = ['<|plamo:tag|>', '<|plamo:bos|>']
const SETTLE_MS = 300
const RETRY_MS = 3000
const MAX_RETRIES = 2
const MAX_PARALLEL = 2
const STORE_LIMIT = 3000
const NOTICE_CHARS = 300

const ENGLISH_SECTION = [
  '# Language',
  'Write every reply to the user in English, whatever language the user writes in, unless the latest plamo-ja note says otherwise. A local translator renders your replies into Japanese for the user, so write plain, unambiguous English. Write terse, declarative technical English, like a commit message or a code review comment: no interjections or conversational filler (yes, sure, good catch, I\'ll go ahead and), no praise of the user; state facts, results and next steps. Keep code, identifiers, file paths and commands as they are.',
].join('\n')
const NOTE_ON =
  '[plamo-ja] Reply in English. Your reply is machine-translated into Japanese for the user. Write terse, declarative technical English, like a commit message or a code review comment: no interjections or conversational filler (yes, sure, good catch, I\'ll go ahead and), no praise of the user; state facts, results and next steps.'
const NOTE_OFF = '[plamo-ja] Translation is off. Reply in Japanese.'

type Options = { endpoint: string; model: string; form: string; ggufPath: string; hfRepo: string; context: string }

function hash(text: string): string {
  let a = 0x811c9dc5
  let b = 0x01000193
  for (let i = 0; i < text.length; i++) {
    const c = text.charCodeAt(i)
    a = Math.imul(a ^ c, 0x01000193) >>> 0
    b = Math.imul(b ^ c, 0x5bd1e995) >>> 0
  }
  return `${a.toString(36)}${b.toString(36)}${text.length.toString(36)}`
}

type Segment = { kind: 'code' | 'text'; body: string }

function segment(markdown: string): Segment[] {
  const segments: Segment[] = []
  let buffer: string[] = []
  let fence: string | null = null
  const flush = (kind: Segment['kind']) => {
    if (buffer.length > 0) segments.push({ kind, body: buffer.join('\n') })
    buffer = []
  }
  for (const line of markdown.split('\n')) {
    const marker = line.match(/^\s*(`{3,}|~{3,})/)?.[1]
    if (fence === null && marker) {
      flush('text')
      fence = marker
      buffer.push(line)
    } else if (fence !== null && marker && marker[0] === fence[0] && marker.length >= fence.length) {
      buffer.push(line)
      flush('code')
      fence = null
    } else {
      buffer.push(line)
    }
  }
  flush(fence === null ? 'text' : 'code')
  return segments
}

function prompt(source: string, form: string, context: string): string {
  return (
    '<|plamo:tag|>dataset<|plamo:msg|>translation' +
    (context ? `<|plamo:tag|>context<|plamo:msg|>${context}` : '') +
    `<|plamo:tag|>input<|plamo:key|>lang<|plamo:val|>en<|plamo:msg|>${source}` +
    `<|plamo:tag|>output<|plamo:key|>lang<|plamo:val|>ja<|plamo:key|>form<|plamo:val|>${form}<|plamo:msg|>`
  )
}

type Piece = { kind: 'code' | 'sep' | 'para'; body: string }

function pieces(markdown: string): Piece[] {
  const out: Piece[] = []
  segment(markdown).forEach((seg, i) => {
    if (i > 0) out.push({ kind: 'sep', body: '\n' })
    if (seg.kind === 'code') {
      out.push({ kind: 'code', body: seg.body })
      return
    }
    seg.body.split(/(\n{2,})/).forEach((part, j) => {
      if (part) out.push({ kind: j % 2 === 1 ? 'sep' : 'para', body: part })
    })
  })
  return out
}

const latestTail = new Map<string, string>()
const inFlight = new Set<string>()
const retries = new Map<string, number>()
const queue: Array<{ id: string; source: string }> = []
const queued = new Set<string>()
let storeChain: Promise<void> = Promise.resolve()
let serverStart: Promise<boolean> | null = null

async function isServerUp($: EngineInterface, options: Options): Promise<boolean> {
  try {
    const res = await $.http.fetch(`${options.endpoint.replace(/\/v1\/?$/, '')}/health`)
    return res.ok
  } catch {
    return false
  }
}

async function startServer($: EngineInterface, options: Options): Promise<boolean> {
  const port = options.endpoint.match(/:(\d+)/)?.[1] ?? '8765'
  const script = [
    'p="$1"',
    'case "$p" in "~/"*) p="$HOME/${p#"~/"}";; esac',
    'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"',
    'command -v llama-server >/dev/null || exit 3',
    'if [ -n "$p" ] && [ -f "$p" ]; then src="-m"; else src="-hf"; p="$4"; fi',
    'nohup llama-server "$src" "$p" -c 16384 --host 127.0.0.1 --port "$2" --alias "$3" --jinja --no-prefill-assistant >"${TMPDIR:-/tmp}/plamo-ja-llama-server.log" 2>&1 </dev/null &',
  ].join('\n')
  const run = await $.process.run(['sh', '-c', script, 'sh', options.ggufPath, port, options.model, options.hfRepo])
  if (run.exitCode !== 0) return false
  for (let i = 0; i < 600; i++) {
    if (await isServerUp($, options)) return true
    await $.clock.sleep(500)
  }
  return false
}

async function complete($: EngineInterface, options: Options, source: string): Promise<string> {
  const res = await $.http.fetch(`${options.endpoint.replace(/\/$/, '')}/completions`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      model: options.model,
      prompt: prompt(source, options.form, options.context),
      temperature: 0,
      max_tokens: Math.max(512, source.length * 2),
      stop: STOP,
    }),
  })
  if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.text.slice(0, 200)}`)
  const text: string = JSON.parse(res.text).choices?.[0]?.text ?? ''
  return text.replace(/<\|plamo:(tag|bos)\|>\s*$/, '').trim()
}

function enqueue($: EngineInterface, options: Options, id: string, source: string) {
  if (queued.has(id) || inFlight.has(id)) return
  queued.add(id)
  queue.push({ id, source })
  pump($, options)
}

// 再開したセッションで古いメッセージが一斉に来ても、新しいものから少しずつ訳す
function pump($: EngineInterface, options: Options) {
  while (inFlight.size < MAX_PARALLEL && queue.length > 0) {
    const job = queue.pop()!
    queued.delete(job.id)
    inFlight.add(job.id)
    void translate($, options, job.id, job.source).finally(() => {
      inFlight.delete(job.id)
      pump($, options)
    })
  }
}

function remember($: EngineInterface, id: string, ja: string): Promise<void> {
  storeChain = storeChain
    .then(async () => {
      await $.store.set(`tr:${id}`, ja)
      const index = ((await $.store.get('index')) as string[] | undefined) ?? []
      index.push(id)
      const dropped = index.splice(0, Math.max(0, index.length - STORE_LIMIT))
      await Promise.all(dropped.map(old => $.store.delete(`tr:${old}`)))
      await $.store.set('index', index)
    })
    .catch(() => {})
  return storeChain
}

async function recall($: EngineInterface, id: string): Promise<string | null> {
  const value = await $.store.get(`tr:${id}`)
  return typeof value === 'string' ? value : null
}

async function translate($: EngineInterface, options: Options, id: string, source: string) {
  const member = memberOf(translations, { requestId: id })
  try {
    await update($, member, (): Translation => ({ status: 'pending' }))
    let ja: string
    try {
      ja = await complete($, options, source)
    } catch (err) {
      if (await isServerUp($, options)) throw err
      serverStart ??= startServer($, options).finally(() => {
        serverStart = null
      })
      if (!(await serverStart)) {
        throw new Error(`翻訳サーバー(${options.endpoint})に接続できず、自動起動もできませんでした（brew install llama.cpp が必要）`)
      }
      ja = await complete($, options, source)
    }
    await update($, member, (): Translation => ({ status: 'done', text: ja }))
    await remember($, id, ja)
  } catch (err) {
    const reason = err instanceof Error ? err.message : String(err)
    await update($, member, (): Translation => ({ status: 'error', reason }))
    const count = retries.get(id) ?? 0
    if (count < MAX_RETRIES) {
      retries.set(id, count + 1)
      $.clock.after(RETRY_MS, () => {
        void update($, member, () => null)
      })
    }
  }
}

async function translateForNotice($: EngineInterface, options: Options, markdown: string): Promise<string> {
  const head = markdown.split(/\n{2,}/).reduce((acc, para) => (acc.length >= NOTICE_CHARS ? acc : acc ? `${acc}\n\n${para}` : para), '')
  const parts = await Promise.all(
    pieces(head).map(async piece => {
      if (piece.kind !== 'para' || !/[A-Za-z]/.test(piece.body)) return piece.body
      const id = hash(`${options.form}\n${options.context}\n${piece.body}`)
      const state = await read($, memberOf(translations, { requestId: id }))
      if (state?.status === 'done') return state.text
      return (await recall($, id)) ?? complete($, options, piece.body)
    }),
  )
  return parts.join('')
}

export const register: Register = (on, rawOptions) => {
  const options = rawOptions as unknown as Options

  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'plamo',
      description: 'PLaMo翻訳のオン・オフを切り替える (on / off / 引数なしでトグル)',
      argumentHint: '[on|off]',
    })
    return next(e)
  })

  on('command.run', { command: 'plamo' }, async ($, e) => {
    const arg = String(e.args ?? '').trim()
    const value = await update($, isEnabled, current => (arg === 'on' ? true : arg === 'off' ? false : !current))
    return { text: value ? 'PLaMo翻訳: オン（Claudeは英語で返答し、日本語訳を表示します）' : 'PLaMo翻訳: オフ' }
  })

  on('prompt.compose', async ($, e, next) => {
    const result = await next(e)
    const isLanguage = (s: { id: string; text: string }) => s.id === 'language' || s.text.startsWith('# Language')
    if (result.sections.some(isLanguage)) {
      return { sections: result.sections.map(s => (isLanguage(s) ? { ...s, text: ENGLISH_SECTION } : s)) }
    }
    return { sections: [...result.sections, { id: 'plamo-ja:language', text: ENGLISH_SECTION, scope: 'session' }] }
  })

  on('prompt.submit', async ($, e, next) => {
    if (e.command) return next(e)
    const note = (await read($, isEnabled)) ? NOTE_ON : NOTE_OFF
    return next({ ...e, context: [...(e.context ?? []), note] })
  }).catch(($, e, next) => next(e))

  on('ui.render', { component: 'AssistantMessage' }, async ($, e, next) => {
    if (!(await read($, isEnabled))) return next(e)
    const source = e.props.text
    if (!/[A-Za-z]/.test(source)) return next(e)

    const list = pieces(source)
    const lastPara = list.map(p => p.kind).lastIndexOf('para')
    let isPending = false
    let failure: string | null = null
    const shown = await Promise.all(
      list.map(async (piece, i) => {
        if (piece.kind !== 'para' || !/[A-Za-z]/.test(piece.body)) return piece.body
        const id = hash(`${options.form}\n${options.context}\n${piece.body}`)
        const state = await read($, memberOf(translations, { requestId: id }))
        if (state?.status === 'done') return state.text
        if (state?.status === 'error') {
          failure = state.reason
          return piece.body
        }
        if (state === null) {
          const cached = await recall($, id)
          if (cached !== null) return cached
          if (e.props.onScreen === null) return piece.body
        }
        isPending = true
        if (state === null) {
          if (i < lastPara || list.slice(i + 1).some(p => p.kind === 'code')) {
            $.clock.after(0, () => {
              enqueue($, options, id, piece.body)
            })
          } else {
            latestTail.set(e.requestId, piece.body)
            $.clock.after(SETTLE_MS, () => {
              if (latestTail.get(e.requestId) === piece.body) enqueue($, options, id, piece.body)
            })
          }
        }
        return piece.body
      }),
    )
    const notes = [isPending ? '*⏳ PLaMo 翻訳中…*' : '', failure ? `> ⚠ PLaMo翻訳に失敗: ${failure}` : ''].filter(Boolean)
    return next({ ...e, props: { ...e.props, text: [shown.join(''), ...notes].join('\n\n') } })
  })

  on('classic.Stop', async ($, e, next) => {
    const message = e.last_assistant_message
    if (!message || !(await read($, isEnabled)) || !/[A-Za-z]/.test(message)) return next(e)
    const ja = await translateForNotice($, options, message)
    return next({ ...e, last_assistant_message: ja })
  }).catch(($, e, next) => next(e))
}
