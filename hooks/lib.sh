# Shared helpers. Bash + grep/sed only (no jq/python/node): runs on macOS, Linux, WSL, Git Bash.
FRESH_DIR="${FRESH_CTX_DIR:-$HOME/.claude/fresh-ctx}"

# json_str <key> <json>: first string value for "key" (unescapes \\ for Windows paths).
json_str() { printf '%s' "$2" | grep -o "\"$1\":\"[^\"]*\"" | head -n1 | sed -e "s/^\"$1\":\"//" -e 's/"$//' -e 's/\\\\/\\/g'; }

# One handoff file per working directory.
handoff_path() { printf '%s/%s.md' "$FRESH_DIR" "$(printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/-/g')"; }

# is_due <session> <used> <window>: true once usage is past FRESH_CTX_PCT of the window or
# FRESH_CTX_TOKENS, whichever comes first (35% of a 1M window is far too late). A session that started
# from a handoff (.handoff-<session>) must also grow FRESH_CTX_MIN_GROWTH points past its first
# reading, so a fresh window that starts high never hands off again straight away.
is_due() {
  [ $(( $2 * 100 / $3 )) -ge "${FRESH_CTX_PCT:-35}" ] || [ "$2" -ge "${FRESH_CTX_TOKENS:-150000}" ] || return 1
  [ -f "$FRESH_DIR/.handoff-$1" ] || return 0
  local base_file="$FRESH_DIR/.base-$1"
  [ -f "$base_file" ] || printf '%s' "$2" > "$base_file"
  [ $(( ($2 - $(cat "$base_file")) * 100 / $3 )) -ge "${FRESH_CTX_MIN_GROWTH:-5}" ]
}
