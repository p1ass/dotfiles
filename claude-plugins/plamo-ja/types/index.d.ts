export type Translation =
  | { status: 'pending' }
  | { status: 'done'; text: string }
  | { status: 'error'; reason: string }

declare module 'claude-code' {
  interface PluginState {
    'plamo-ja': {
      isEnabled: boolean
      translations: StateFamily<Translation | null>
    }
  }
}
