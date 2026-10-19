#!/usr/bin/env bash
# PostToolUse + UserPromptSubmit: once context crosses FRESH_CTX_PCT, tell Claude to hand off.
. "$(dirname "$0")/lib.sh"
input=$(cat)
transcript=$(json_str transcript_path "$input")
session=$(json_str session_id "$input")
event=$(json_str hook_event_name "$input")
[ -f "$transcript" ] && [ -n "$session" ] || exit 0

# Remember the session folder so save.sh writes where reload.sh will look, even after a cd.
cwd=$(json_str cwd "$input")
mkdir -p "$FRESH_DIR"; [ -n "$cwd" ] && [ ! -f "$FRESH_DIR/.cwd-$session" ] && printf '%s' "$cwd" > "$FRESH_DIR/.cwd-$session"

flag="$FRESH_DIR/.fired-$session"
[ -f "$flag" ] && exit 0

# Last main-thread assistant turn: input + cache read + cache write = tokens in context.
last=$(tail -n 300 "$transcript" | grep '"type":"assistant"' | grep -v '"isSidechain":true' | grep '"usage"' | tail -n 1)
[ -n "$last" ] || exit 0
num() { n=$(printf '%s' "$last" | grep -o "\"$1\":[0-9]*" | head -n1 | sed 's/.*://'); echo "${n:-0}"; }
used=$(( $(num input_tokens) + $(num cache_read_input_tokens) + $(num cache_creation_input_tokens) ))

window="${FRESH_CTX_WINDOW:-200000}"
pct=$(( used * 100 / window ))
[ "$pct" -ge "${FRESH_CTX_PCT:-35}" ] || exit 0

: > "$flag"
msg="[fresh-ctx] Context is at ${pct}% (${used} of ${window} tokens). Finish the step you are on (do not start a new one), then run the fresh-ctx skill: write the handoff, then stop and ask the user to type /clear. The handoff reloads automatically after /clear."
printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "${event:-PostToolUse}" "$msg"
