import type { Register } from 'claude-code'

// The automatic half of fresh-ctx. When a main-thread turn ends:
//  - a handoff is waiting for this session → /clear, then submit the handoff as the next prompt;
//  - context is past the threshold with no handoff yet → ask Claude to write one (once per session).
// Paths and env live in bash (hooks/mod.sh) so the mod and the shell hooks agree on them.
const field = (input: unknown, key: string): string => {
  const value = (input as Record<string, unknown> | null)?.[key]
  return typeof value === 'string' ? value : ''
}

export const register: Register = on => {
  const nudged = new Set<string>()

  // The handoff must never wait on a permission prompt: allow the skill and its save script, nothing else.
  on('tool.check', { tool: 'Skill' }, ($, e, next) =>
    /(^|:)fresh-ctx$/.test(field(e.input, 'skill')) ? { decision: 'allow' } : next(e))
  on('tool.check', { tool: 'Bash' }, ($, e, next) =>
    field(e.input, 'command').startsWith(`bash "${$.plugin.root}/skills/fresh-ctx/save.sh"`) ? { decision: 'allow' } : next(e))

  on('session.measure', async ($, e, next) => {
    if (e.context.window) await $.process.run(['bash', `${$.plugin.root}/hooks/mod.sh`, 'window', String(e.context.window)])
    return next(e)
  })

  on('turn.complete', async ($, e, next) => {
    const done = await next(e)
    if (e.agentId || e.isAborted) return done

    const sid = await $.session.id()
    const sh = (...args: string[]) => $.process.run(['bash', `${$.plugin.root}/hooks/mod.sh`, ...args])

    void (async () => {
      const handoff = (await sh('take', sid)).stdout.trim()
      if (handoff) {
        $.ui.toast('fresh-ctx: clearing context and reloading the handoff')
        await $.command.run({ command: 'clear' })
        await sh('mark', await $.session.id())
        await $.prompt.submit({ text: `[fresh-ctx] Handoff from the previous context window. Continue from here; do not redo finished work.\n\n${handoff}` })
        return
      }
      const { context } = await $.session.usage()
      if (!context.tokens || nudged.has(sid)) return
      if ((await sh('due', sid, String(context.tokens), String(context.window))).stdout.trim() !== 'yes') return
      nudged.add(sid)
      await $.prompt.submit({ text: `[fresh-ctx] Context is at ${context.percent}%. Run the fresh-ctx skill now: write the handoff and stop.` })
    })().catch(err => $.ui.toast(`fresh-ctx: ${String(err)}`))

    return done
  })
}
