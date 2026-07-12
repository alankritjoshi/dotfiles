#!/bin/sh

gh=''

# Git repo root if inside one, else the current directory.
# One git call, which also doubles as the in-repo check.
repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$repo_path" ] && display="$repo_path" || display="$PWD"

name=${display##*/}

case "$display" in
"$HOME") printf "~" ;;
"$HOME"/world) printf "🌍" ;;
"$HOME"/world/*) printf "🌍/%s" "$name" ;;
*/github.com/Shopify/*) printf "🛍️/%s" "$name" ;;
*/github.com/*) printf "%s/%s" "$gh" "$name" ;;
"$HOME"/*) printf "~%s" "${display#"$HOME"}" ;;
*) printf "%s" "$display" ;;
esac
