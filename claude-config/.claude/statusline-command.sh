#!/usr/bin/env bash
# Claude Code statusLine script — Catppuccin Mocha theme (mirrors Starship config)
#
# Catppuccin Mocha palette (ANSI 24-bit)
#   surface0 = #313244  peach   = #fab387  green = #a6e3a1
#   teal     = #94e2d5  blue    = #89b4fa  base  = #1e1e2e
#   mantle   = #181825  text    = #cdd6f4  overlay1 = #7f849c

input=$(cat)

ESC=$(printf '\033')

# Catppuccin Mocha colors (fg only; status line renders on dimmed background)
surface0_fg="${ESC}[38;2;49;50;68m"    # #313244
peach_fg="${ESC}[38;2;250;179;135m"    # #fab387
green_fg="${ESC}[38;2;166;227;161m"    # #a6e3a1
teal_fg="${ESC}[38;2;148;226;213m"     # #94e2d5
blue_fg="${ESC}[38;2;137;180;250m"     # #89b4fa
text_fg="${ESC}[38;2;205;214;244m"     # #cdd6f4
overlay1_fg="${ESC}[38;2;127;132;156m" # #7f849c
red_fg="${ESC}[38;2;243;139;168m"      # #f38ba8
yellow_fg="${ESC}[38;2;249;226;175m"   # #f9e2af
reset="${ESC}[0m"
dim="${ESC}[2m"

# ── Data from Claude ──────────────────────────────────────────────────────────
username=$(whoami)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
# `current_usage.input_tokens` only counts new uncached input — real context
# usage is the sum of input + output + cache_creation + cache_read.
used_tokens=$(echo "$input" | jq -r '
  .context_window.current_usage
  | (.input_tokens // 0) + (.output_tokens // 0)
    + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
  | select(. > 0) // empty')

effort=$(echo "$input" | jq -r '.effort.level // empty')

# ── Directory (truncated like Starship: max 3 segments, …/ prefix) ────────────
short_dir=$(echo "$current_dir" | sed "s|$HOME|~|")
segment_count=$(echo "$short_dir" | tr -cd '/' | wc -c | tr -d ' ')
if [ "$segment_count" -gt 3 ]; then
  short_dir=$(echo "$short_dir" | awk -F'/' '{n=NF; printf "…/"; for(i=n-2;i<=n;i++){printf "%s",$i; if(i<n) printf "/"}}')
fi

# ── Git info ──────────────────────────────────────────────────────────────────
git_info=""
if [ -n "$current_dir" ] && cd "$current_dir" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  [ -n "$git_branch" ] && git_info=" ${green_fg} ${git_branch}${reset}"
fi

# ── Context window ────────────────────────────────────────────────────────────
ctx_info=""
if [ -n "$remaining" ]; then
  remaining_int=$(printf '%.0f' "$remaining")
  used_int=$((100 - remaining_int))

  # Format token count: show in k if >= 1000
  token_str=""
  if [ -n "$used_tokens" ] && [ "$used_tokens" -gt 0 ] 2>/dev/null; then
    if [ "$used_tokens" -ge 1000 ]; then
      token_str=$(awk "BEGIN { printf \"%.1fk\", $used_tokens/1000 }")
    else
      token_str="$used_tokens"
    fi
  fi

  if [ "$remaining_int" -le 20 ]; then
    color="$red_fg"
  elif [ "$remaining_int" -le 50 ]; then
    color="$yellow_fg"
  else
    color="$teal_fg"
  fi

  if [ -n "$token_str" ]; then
    ctx_info=" ${color}${ESC}[1m${token_str} tokens${reset}${color} (${used_int}% used)${reset}"
  else
    ctx_info=" ${color}${ESC}[1m${used_int}% ctx used${reset}"
  fi
fi

# ── Effort level ──────────────────────────────────────────────────────────────
effort_info=""
if [ -n "$effort" ]; then
  case "$effort" in
    high)   effort_color="$red_fg" ;;
    medium) effort_color="$yellow_fg" ;;
    low)    effort_color="$teal_fg" ;;
    *)      effort_color="$overlay1_fg" ;;
  esac
  effort_info=" ${dim}·${reset} ${effort_color}${effort}${reset}"
fi

# ── Assemble ──────────────────────────────────────────────────────────────────
# Build left and right segments separately, then pad to right-align the token
# block. ctx_info has a literal `%` (e.g. "6% used") — never put it inside a
# printf format string, only pass it as %s.
left=$(printf ' %s%s%s %s%s%s%s %s%s%s%s' \
  "$blue_fg" "$username" "$reset" \
  "$peach_fg" "$short_dir" "$reset" \
  "$git_info" \
  "$dim" "$model_name" "$reset" \
  "$effort_info")
right="$ctx_info "

if [ -n "$ctx_info" ]; then
  # Width detection: prefer COLUMNS, fall back to tput/stty (need /dev/tty
  # because stdout is a pipe to Claude Code, not the terminal).
  cols="${COLUMNS:-}"
  [ -z "$cols" ] && cols=$(tput cols 2>/dev/null </dev/tty)
  [ -z "$cols" ] && cols=$(stty size 2>/dev/null </dev/tty | awk '{print $2}')
  [ -z "$cols" ] && cols=80

  # Visible-character count = string with all CSI escapes stripped.
  strip_ansi() { printf '%s' "$1" | sed $'s/\x1b\\[[0-9;]*[a-zA-Z]//g'; }
  left_visible=$(strip_ansi "$left")
  right_visible=$(strip_ansi "$right")

  pad=$(( cols - ${#left_visible} - ${#right_visible} ))
  [ "$pad" -lt 1 ] && pad=1

  printf '%s%*s%s' "$left" "$pad" "" "$right"
else
  printf '%s' "$left"
fi
