#!/usr/bin/env bash
# Claude Code status line: user | dir | git | model | context used
input=$(cat)

j() { echo "$input" | jq -r "$1"; }

ESC=$(printf '\033')
username=$(whoami)
current_dir=$(j '.workspace.current_dir')
model_name=$(j '.model.display_name // .model.id')

# --- token / context info -------------------------------------------------
cur_in=$(j '.context_window.current_usage.input_tokens // 0')
cur_cc=$(j '.context_window.current_usage.cache_creation_input_tokens // 0')
cur_cr=$(j '.context_window.current_usage.cache_read_input_tokens // 0')
ctx_used=$((cur_in + cur_cc + cur_cr))
pct=$(j '.context_window.used_percentage // 0' | cut -d. -f1)

fmt_k() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then awk -v n="$n" 'BEGIN{printf "%.1fM", n/1000000}'
  elif [ "$n" -ge 1000 ]; then awk -v n="$n" 'BEGIN{printf "%.0fk", n/1000}'
  else echo "$n"; fi
}

# colour the context % by pressure
if [ "$pct" -ge 80 ]; then pc="${ESC}[31m"
elif [ "$pct" -ge 50 ]; then pc="${ESC}[33m"
else pc="${ESC}[32m"; fi

ctx_str="${pc}$(fmt_k "$ctx_used") ${pct}%${ESC}[0m"

# --- git ----------------------------------------------------------------------
cd "$current_dir" 2>/dev/null
git_info=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  git_status=$(git --no-optional-locks status --porcelain 2>/dev/null)
  staged=$(echo "$git_status" | grep -c '^[AMDR]')
  modified=$(echo "$git_status" | grep -c '^.[M]')
  deleted=$(echo "$git_status" | grep -c '[D]')
  untracked=$(echo "$git_status" | grep -c '^??')
  s=""
  [ "$staged" -gt 0 ] && s="$s ${ESC}[32mA:${staged}${ESC}[0m"
  [ "$modified" -gt 0 ] && s="$s ${ESC}[33mM:${modified}${ESC}[0m"
  [ "$deleted" -gt 0 ] && s="$s ${ESC}[31mD:${deleted}${ESC}[0m"
  [ "$untracked" -gt 0 ] && s="$s ${ESC}[36mU:${untracked}${ESC}[0m"
  git_info=" | ${ESC}[36m${git_branch}*${ESC}[0m${s}"
fi

short_dir=$(echo "$current_dir" | awk -F'/' '{n=NF; if(n<=3) print; else {printf "…/"; for(i=n-2;i<=n;i++){printf "%s", $i; if(i<n) printf "/"}}}')

printf "${ESC}[34m%s${ESC}[0m | [${ESC}[35m%s${ESC}[0m]%s | ${ESC}[2m%s${ESC}[0m | %s" \
  "$username" "$short_dir" "$git_info" "$model_name" "$ctx_str"
