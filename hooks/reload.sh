#!/usr/bin/env bash
# SessionStart(clear|startup): inject the handoff saved for this folder, then archive it so it loads once.
. "$(dirname "$0")/lib.sh"
input=$(cat)
cwd=$(json_str cwd "$input"); [ -n "$cwd" ] || cwd="$PWD"
file=$(handoff_path "$cwd")
[ -f "$file" ] || exit 0
echo "[fresh-ctx] Handoff from the previous context window. Continue from here; do not redo finished work."
echo
cat "$file"
mv "$file" "$file.loaded"
