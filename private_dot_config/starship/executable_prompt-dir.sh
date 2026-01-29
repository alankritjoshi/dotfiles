#!/bin/sh

gh=''
stack_icon=''
wt_icon='󰙅'

get_stack() {
  # No stack on trunk branches; clean up stale file
  current_branch=$(git branch --show-current 2>/dev/null)
  case "$current_branch" in main|master) rm -f .graphite; return ;; esac

  [ ! -f ".graphite" ] && return
  content=$(cat ".graphite")
  echo "$content" | grep -q "^ERROR" && return
  total_lines=$(echo "$content" | wc -l | tr -d ' ')
  [ "$total_lines" -lt 3 ] && return
  current_line=$(echo "$content" | grep -n "◉" | cut -d: -f1)
  [ -z "$current_line" ] && return
  printf "%s %d/%d" "$stack_icon" $((current_line - 1)) $((total_lines - 1))
}

build_suffix() {
  wt="$1"
  stack="$2"
  [ -z "$wt" ] && [ -z "$stack" ] && return
  if [ -n "$wt" ] && [ -n "$stack" ]; then
    printf " (%s %s %s)" "$wt_icon" "$wt" "$stack"
  elif [ -n "$wt" ]; then
    printf " (%s %s)" "$wt_icon" "$wt"
  else
    printf " (%s)" "$stack"
  fi
}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  pwd | sed "s|^$HOME|~|"
  exit 0
fi

common=$(git rev-parse --git-common-dir 2>/dev/null)
gitdir=$(git rev-parse --git-dir 2>/dev/null)
stack=$(get_stack)

if [ "$common" != "$gitdir" ]; then
  repo_path=$(echo "$common" | sed 's|/\.git$||')
  repo_name=$(basename "$repo_path")
  wt_name=$(basename "$(pwd)")
else
  repo_path=$(git rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$repo_path" ]; then
    # Fallback for bare repos
    repo_path=$(pwd)
  fi
  repo_name=$(basename "$repo_path")
  wt_name=""
fi

suffix=$(build_suffix "$wt_name" "$stack")

case "$repo_path" in
*/github.com/Shopify/*) printf "🛍️/%s%s" "$repo_name" "$suffix" ;;
*/github.com/*) printf "%s/%s%s" "$gh" "$repo_name" "$suffix" ;;
*) printf "%s%s" "$repo_name" "$suffix" ;;
esac
