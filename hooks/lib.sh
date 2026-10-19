# Shared helpers. Bash + grep/sed only (no jq/python/node): runs on macOS, Linux, WSL, Git Bash.
FRESH_DIR="${FRESH_CTX_DIR:-$HOME/.claude/fresh-ctx}"

# json_str <key> <json>: first string value for "key" (unescapes \\ for Windows paths).
json_str() { printf '%s' "$2" | grep -o "\"$1\":\"[^\"]*\"" | head -n1 | sed -e "s/^\"$1\":\"//" -e 's/"$//' -e 's/\\\\/\\/g'; }

# One handoff file per working directory.
handoff_path() { printf '%s/%s.md' "$FRESH_DIR" "$(printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/-/g')"; }

# is_due <session> <used> <window>: true once usage is past FRESH_CTX_PCT and the session has
# grown FRESH_CTX_MIN_GROWTH points since its first reading (so a fresh window never re-triggers).
is_due() {
  local base_file="$FRESH_DIR/.base-$1" base
  mkdir -p "$FRESH_DIR"; [ -f "$base_file" ] || printf '%s' "$2" > "$base_file"
  base=$(cat "$base_file")
  [ $(( $2 * 100 / $3 )) -ge "${FRESH_CTX_PCT:-35}" ] && [ $(( ($2 - base) * 100 / $3 )) -ge "${FRESH_CTX_MIN_GROWTH:-5}" ]
}
