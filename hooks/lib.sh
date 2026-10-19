# Shared helpers. Bash + grep/sed only (no jq/python/node): runs on macOS, Linux, WSL, Git Bash.
FRESH_DIR="${FRESH_CTX_DIR:-$HOME/.claude/fresh-ctx}"

# json_str <key> <json>: first string value for "key" (unescapes \\ for Windows paths).
json_str() { printf '%s' "$2" | grep -o "\"$1\":\"[^\"]*\"" | head -n1 | sed -e "s/^\"$1\":\"//" -e 's/"$//' -e 's/\\\\/\\/g'; }

# One handoff file per working directory.
handoff_path() { printf '%s/%s.md' "$FRESH_DIR" "$(printf '%s' "$1" | sed 's/[^A-Za-z0-9._-]/-/g')"; }
