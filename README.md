# fresh-ctx

Stops long Claude sessions from rotting. At **~35% context** Claude finishes its current step, writes a handoff, and asks you to type `/clear`. The handoff then **reloads by itself**, so there is nothing to copy or paste.

## Claude Code (terminal, or the Code tab in the desktop app): automatic

```
/plugin marketplace add /path/to/fresh-ctx
/plugin install fresh-ctx@fresh-ctx
```
Restart Claude Code. From then on:

1. Context crosses 35% → Claude wraps up the current step and saves a handoff (also copied to the clipboard).
2. You type `/clear`.
3. The new window starts with the handoff loaded and continues.

Type `fresh ctx` any time to hand off early.

| Setting (env var) | Default | Meaning |
|---|---|---|
| `FRESH_CTX_PCT` | `35` | Trigger point, % of window |
| `FRESH_CTX_WINDOW` | `200000` | Context window size in tokens (set `1000000` for 1M models) |
| `FRESH_CTX_DIR` | `~/.claude/fresh-ctx` | Where handoffs live (one per project folder) |

Set these in `~/.claude/settings.json` under `"env"`.

Requires only bash (macOS, Linux, WSL; on Windows, the Git Bash that Claude Code already uses).

## Claude chat app (claude.ai / desktop chat): manual

The chat app has no hooks and no `/clear`, so this version can't be automatic. Upload `fresh-ctx-chat.zip` under **Settings → Capabilities → Skills**. Say `fresh ctx` (Claude also offers it when a chat gets long), copy the block it gives you, open a new chat, and paste it in.

## Limits
- Claude can't run `/clear` itself, so typing it is the one manual step.
- The trigger fires once per session. If you ignore it, Claude keeps working.
- A handoff is loaded once, on the next `/clear` or new session in the same folder, and then archived as `.md.loaded`.
