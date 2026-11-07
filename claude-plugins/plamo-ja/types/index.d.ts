export type Translation =
  | { status: 'pending' }
  | { status: 'done'; text: string }
  | { status: 'error'; reason: string }

declare module 'claude-code' {
  interface PluginState {
    'plamo-ja': {
      isEnabled: boolean
      size: string | null
      translations: StateFamily<Translation | null>
    }
  }
}
