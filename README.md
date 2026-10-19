# fresh-ctx

Stops long Claude sessions from rotting. At **~35% context** Claude finishes its current step and writes a handoff. Then the context is **cleared and the handoff submitted as the next prompt automatically**, and the work continues in a fresh window. Nothing to type, copy or paste.

## Claude Code (terminal, or the Code tab in the desktop app): automatic

Inside Claude Code:
```
/plugin marketplace add hasuwini77/fresh-ctx
/plugin install fresh-ctx@fresh-ctx
```
Update later with `/plugin marketplace update fresh-ctx`.
Restart Claude Code. From then on:

1. Context crosses 35% → a hook tells Claude to finish its current step, write a handoff and stop.
2. When that turn ends, the fresh-ctx **mod** runs `/clear` and submits the handoff as the next prompt.
3. Claude continues the job in a clean window. This repeats for as long as the job runs.

Type `fresh ctx` any time to hand off early.

| Setting (env var) | Default | Meaning |
|---|---|---|
| `FRESH_CTX_PCT` | `35` | Trigger point, % of window |
| `FRESH_CTX_MIN_GROWTH` | `5` | A session that started from a handoff must grow this many points before handing off again (stops loops) |
| `FRESH_CTX_WINDOW` | auto | Window size; read from the session, override only if needed |
| `FRESH_CTX_DIR` | `~/.claude/fresh-ctx` | Where handoffs live (one per project folder) |

Set these in `~/.claude/settings.json` under `"env"`.

Works in any permission mode: the mod approves only the fresh-ctx skill and its save script, so a handoff never waits on a prompt. Subagent tool calls are ignored.

Requires bash. Tested on Linux/WSL; macOS should work; native Windows is untested.

## Claude chat app (claude.ai / desktop chat): manual

The chat app has no hooks and no `/clear`, so this version can't be automatic. Download [`fresh-ctx-chat.zip`](fresh-ctx-chat.zip) and upload it under **Settings → Capabilities → Skills**. Say `fresh ctx` (Claude also offers it when a chat gets long), copy the block it gives you, open a new chat, and paste it in.

## Limits
- On a 1M-token model, 35% is 350k tokens. Set `FRESH_CTX_PCT` lower (e.g. `15`) if you want handoffs sooner.
- Automatic clear needs a host that loads mods. Tested in the terminal CLI; the desktop app's Code tab is untested. Without mods, Claude stops and asks you to type `/clear`, and the handoff still reloads by itself.
- Pressing Esc on a turn skips the automatic step for that turn.
- A handoff is loaded once, then archived as `.md.loaded` in `~/.claude/fresh-ctx/`.
