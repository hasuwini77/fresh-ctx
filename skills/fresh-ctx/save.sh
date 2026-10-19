#!/usr/bin/env bash
# Usage: bash save.sh <<'HANDOFF' ... HANDOFF
# Saves the handoff for the current folder and copies it to the clipboard (best effort).
. "$(dirname "$0")/../../hooks/lib.sh"
mkdir -p "$FRESH_DIR"
root="$PWD"
[ -n "$CLAUDE_CODE_SESSION_ID" ] && [ -f "$FRESH_DIR/.cwd-$CLAUDE_CODE_SESSION_ID" ] && root=$(cat "$FRESH_DIR/.cwd-$CLAUDE_CODE_SESSION_ID")
file=$(handoff_path "$root")
cat > "$file"
# Tell the mod a handoff is waiting for this session.
[ -n "$CLAUDE_CODE_SESSION_ID" ] && printf '%s' "$file" > "$FRESH_DIR/.pending-$CLAUDE_CODE_SESSION_ID"
clip=none
if command -v pbcopy >/dev/null; then pbcopy < "$file" && clip=pbcopy
elif command -v clip.exe >/dev/null; then clip.exe < "$file" && clip=clip.exe
elif command -v clip >/dev/null; then clip < "$file" && clip=clip
elif command -v wl-copy >/dev/null; then wl-copy < "$file" && clip=wl-copy
elif command -v xclip >/dev/null; then xclip -selection clipboard < "$file" && clip=xclip
fi
echo "saved: $file ($(wc -c < "$file") bytes) clipboard: $clip"
