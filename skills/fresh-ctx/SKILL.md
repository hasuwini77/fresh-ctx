---
name: fresh-ctx
description: Write a handoff and move to a fresh context window. Use when a "[fresh-ctx]" hook message says context is high, when the user says "fresh ctx", "handoff", "new context" or "clear and continue", or before starting a big new phase in a long session.
---

# fresh-ctx

Long sessions get worse past ~35% context: slower, pricier, more forgetful. Move the work to a clean window.

## Steps

1. **Finish the current step.** Don't start new work. If a long command is running, let it finish or note its state.
2. **Write the handoff** and save it with the script below. Keep it under ~60 lines. Facts, not story:

```bash
bash "${CLAUDE_SKILL_DIR}/save.sh" <<'HANDOFF'
# Handoff — <task in one line>

## Goal
<what "done" looks like>

## Done so far
- <finished item, with file paths>

## Current state
- Branch / last commit: <...>
- Running or half-done: <command, job, or edit in progress>
- Tests / build: <last result, pass or fail, with the command>

## Next steps
1. <next concrete action>
2. <...>

## Key files
- `path/to/file` — <why it matters>

## Gotchas and decisions
- <dead ends already tried, constraints, choices the user made>
HANDOFF
```

3. **Stop.** End your turn with one line: "Handoff saved. Clearing context and continuing automatically. If nothing happens, type **/clear**."

Do not keep working after step 3. The fresh-ctx mod clears context and submits the handoff as the next prompt. Without the mod (e.g. a host that doesn't load mods), `/clear` or a new session in the same folder reloads it.
