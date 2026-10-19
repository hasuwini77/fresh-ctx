#!/usr/bin/env bash
# PostToolUse + UserPromptSubmit: once context crosses FRESH_CTX_PCT, tell Claude to hand off.
. "$(dirname "$0")/lib.sh"
input=$(cat)
transcript=$(json_str transcript_path "$input")
session=$(json_str session_id "$input")
event=$(json_str hook_event_name "$input")
[ -f "$transcript" ] && [ -n "$session" ] || exit 0
# Subagent tool calls: never measure or nudge from inside a subagent.
[ -n "$(json_str agent_id "$input")" ] && exit 0

# Remember the session folder so save.sh writes where reload.sh will look, even after a cd.
cwd=$(json_str cwd "$input")
mkdir -p "$FRESH_DIR"; [ -n "$cwd" ] && [ ! -f "$FRESH_DIR/.cwd-$session" ] && printf '%s' "$cwd" > "$FRESH_DIR/.cwd-$session"

flag="$FRESH_DIR/.fired-$session"

# Last main-thread assistant turn: input + cache read + cache write = tokens in context.
last=$(tail -n 300 "$transcript" | grep '"type":"assistant"' | grep -v '"isSidechain":true' | grep '"usage"' | tail -n 1)
[ -n "$last" ] || exit 0
num() { n=$(printf '%s' "$last" | grep -o "\"$1\":[0-9]*" | head -n1 | sed 's/.*://'); echo "${n:-0}"; }
used=$(( $(num input_tokens) + $(num cache_read_input_tokens) + $(num cache_creation_input_tokens) ))

window="${FRESH_CTX_WINDOW:-$(cat "$FRESH_DIR/.window" 2>/dev/null || echo 200000)}"
pct=$(( used * 100 / window ))
is_due "$session" "$used" "$window" || exit 0
# Nudge once, then again every FRESH_CTX_RENUDGE tokens if Claude keeps going without a handoff.
[ -f "$flag" ] && [ $(( used - $(cat "$flag") )) -lt "${FRESH_CTX_RENUDGE:-50000}" ] && exit 0

printf '%s' "$used" > "$flag"
msg="[fresh-ctx] Context is at ${pct}% (${used} of ${window} tokens). Finish the step you are on (do not start a new one), then run the fresh-ctx skill: write the handoff and stop. Context is then cleared and the handoff reloaded automatically."
printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "${event:-PostToolUse}" "$msg"
