#!/usr/bin/env bash
# Helper for register.ts:  window <tokens> | take <session_id> | due <session_id> <tokens> <window>
. "$(dirname "$0")/lib.sh"
case "$1" in
  window) mkdir -p "$FRESH_DIR" && printf '%s' "$2" > "$FRESH_DIR/.window" ;;
  due) is_due "$2" "$3" "$4" && echo yes ;;
  take)
    pending="$FRESH_DIR/.pending-$2"
    [ -f "$pending" ] || exit 0
    file=$(cat "$pending"); rm -f "$pending"
    [ -f "$file" ] || exit 0
    cat "$file"; mv "$file" "$file.loaded" ;;
esac
