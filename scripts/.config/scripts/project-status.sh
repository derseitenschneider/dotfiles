#!/bin/zsh
# Project status dashboard — triggered via tmux prefix+P
# Auto-discovers repos, shows active/parked/dormant projects,
# night agent state, and WP client activity.

setopt PIPE_FAIL

# ── Config ─────────────────────────────────────────────
PARKED_THRESHOLD_DAYS=14
STALE_THRESHOLD_DAYS=14
NIGHT_AGENT_REPO="derseitenschneider/eleno"

DISCOVER_PATHS=(
  "$HOME/dev/personal"
  "$HOME/dev/work"
)
WP_PLUGINS_PATH="$HOME/dev/wp-local/sites"

# ── Colors ─────────────────────────────────────────────
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
CYAN=$'\033[36m'
MAGENTA=$'\033[35m'
WHITE=$'\033[37m'

# ── Helpers ────────────────────────────────────────────
format_age() {
  local days=$1
  if (( days == 0 )); then print "today"
  elif (( days == 1 )); then print "1d"
  elif (( days < 7 )); then print "${days}d"
  elif (( days < 30 )); then print "$(( days / 7 ))w"
  else print "$(( days / 30 ))mo"
  fi
}

staleness_color() {
  local days=$1
  if (( days <= 2 )); then print -n "$GREEN"
  elif (( days <= 7 )); then print -n "$YELLOW"
  else print -n "$RED"
  fi
}

days_ago_from_epoch() {
  local epoch=$1
  local now=$(date +%s)
  print $(( (now - epoch) / 86400 ))
}

# ── Gather tmux state ─────────────────────────────────
# session -> list of windows; for each window, the pane path
typeset -A TMUX_SESSIONS
typeset -a TMUX_WINDOW_DATA  # "session|window_name|pane_path" lines

gather_tmux() {
  local line
  for line in "${(@f)$(tmux list-windows -a -F '#{session_name}|#{window_name}|#{pane_current_path}' 2>/dev/null)}"; do
    local session=${line%%|*}
    TMUX_SESSIONS[$session]=1
    TMUX_WINDOW_DATA+=("$line")
  done
}

# ── Discover repos ─────────────────────────────────────
discover_repos() {
  local p
  for p in $DISCOVER_PATHS; do
    for dir in $p/*(N/); do
      [[ -d "$dir/.git" ]] && print "$dir"
    done
  done
}

discover_wp_plugins() {
  [[ -d "$WP_PLUGINS_PATH" ]] || return
  local site plugins_dir plugin
  for site in $WP_PLUGINS_PATH/*(N/); do
    plugins_dir="$site/wp-content/plugins"
    [[ -d "$plugins_dir" ]] || continue
    for plugin in $plugins_dir/*(N/); do
      [[ -d "$plugin/.git" ]] && print "$plugin"
    done
  done
}

# ── Repo info ──────────────────────────────────────────
repo_last_commit_days() {
  local repo=$1
  local epoch
  epoch=$(git -C "$repo" log -1 --format='%ct' 2>/dev/null) || { print "999"; return }
  [[ -z "$epoch" ]] && { print "999"; return }
  days_ago_from_epoch $epoch
}

repo_recent_branches() {
  local repo=$1 threshold=$2
  local now=$(date +%s)
  local line
  for line in "${(@f)$(git -C "$repo" for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:unix)' refs/heads/ 2>/dev/null)}"; do
    local branch=${line% *}
    local epoch=${line##* }
    [[ "$branch" == "main" || "$branch" == "master" ]] && continue
    local days=$(( (now - epoch) / 86400 ))
    (( days <= threshold )) && print "$branch $days"
  done
}

# ── Night agent ────────────────────────────────────────
gather_night_agent() {
  gh issue list --repo "$NIGHT_AGENT_REPO" --state open \
    --json number,title,labels,body,createdAt \
    --jq '.[] | select(.labels | map(.name) | any(startswith("nightagent"))) |
      {
        number: .number,
        title: .title,
        status: (.labels | map(.name) | map(select(startswith("nightagent-"))) | first // "nightagent"),
        parent_prd: (if (.body | test("## Parent PRD[\\s\\n]+#[0-9]+")) then (.body | capture("## Parent PRD[\\s\\n]+#(?<prd>[0-9]+)") | .prd) else null end),
        created: (.createdAt | split("T")[0])
      }' 2>/dev/null
}

render_night_agent() {
  local issues_json=$1
  [[ -z "$issues_json" ]] && return

  local report_line=""
  local -a needs_human skipped done_standalone output_lines
  typeset -A prd_groups prd_counts prd_done_counts

  local line
  for line in "${(@f)$(print "$issues_json" | jq -c '.')}"; do
    [[ -z "$line" ]] && continue
    local num=$(print "$line" | jq -r '.number')
    local issue_status=$(print "$line" | jq -r '.status')
    local title=$(print "$line" | jq -r '.title' | cut -c1-45)
    local parent=$(print "$line" | jq -r '.parent_prd // empty')
    local created=$(print "$line" | jq -r '.created')

    case "$issue_status" in
      nightagent-report)
        local now_epoch=$(date +%s)
        local created_epoch=$(date -j -f "%Y-%m-%d" "$created" +%s 2>/dev/null || print "$now_epoch")
        local age_days=$(( (now_epoch - created_epoch) / 86400 ))
        report_line="  ${DIM}report: #${num} ($(format_age $age_days) ago)${RESET}"
        ;;
      nightagent-needs-human)
        needs_human+=("  ${YELLOW}⚠${RESET} #${num} ${title}")
        ;;
      nightagent-skipped)
        skipped+=("  ${DIM}○ #${num} ${title}${RESET}")
        ;;
      nightagent-done)
        if [[ -n "$parent" ]]; then
          prd_groups[$parent]+="    ${GREEN}✓${RESET} #${num} ${title}"$'\n'
          prd_counts[$parent]=$(( ${prd_counts[$parent]:-0} + 1 ))
          prd_done_counts[$parent]=$(( ${prd_done_counts[$parent]:-0} + 1 ))
        else
          done_standalone+=("  ${GREEN}✓${RESET} #${num} ${title}")
        fi
        ;;
      nightagent)
        if [[ -n "$parent" ]]; then
          prd_groups[$parent]+="    ${DIM}… #${num} ${title}${RESET}"$'\n'
          prd_counts[$parent]=$(( ${prd_counts[$parent]:-0} + 1 ))
        fi
        ;;
    esac
  done

  local box_width=58
  local hline="${DIM}$(printf '─%.0s' {1..$box_width})${RESET}"

  output_lines+=("  ┌${hline}┐")
  output_lines+=("  │ ${BOLD}night agent${RESET}$(printf ' %.0s' {1..$(( box_width - 12 ))})│")
  output_lines+=("  ├${hline}┤")

  local l
  for l in "${needs_human[@]}"; do
    [[ -n "$l" ]] && output_lines+=("  │${l}│")
  done

  local prd
  for prd in ${(k)prd_groups}; do
    local total=${prd_counts[$prd]:-0}
    local done_count=${prd_done_counts[$prd]:-0}
    local prd_title
    prd_title=$(gh issue view "$prd" --repo "$NIGHT_AGENT_REPO" --json title --jq '.title' 2>/dev/null | cut -c1-40)
    output_lines+=("  │ ${CYAN}#${prd}${RESET} ${prd_title} ${DIM}[${done_count}/${total} done]${RESET}")
    local slice_line
    for slice_line in "${(@f)${prd_groups[$prd]}}"; do
      [[ -n "$slice_line" ]] && output_lines+=("  │${slice_line}")
    done
  done

  for l in "${done_standalone[@]}"; do
    [[ -n "$l" ]] && output_lines+=("  │${l}")
  done

  for l in "${skipped[@]}"; do
    [[ -n "$l" ]] && output_lines+=("  │${l}")
  done

  [[ -n "$report_line" ]] && output_lines+=("  │${report_line}")
  output_lines+=("  └${hline}┘")

  for l in "${output_lines[@]}"; do
    print "$l"
  done
}

# ── Get feature windows for a session ──────────────────
get_feature_windows() {
  local session=$1
  local skip_pattern="^(nvim|processes|process|GIT|git|cc|zsh|main)$"
  local entry
  for entry in "${TMUX_WINDOW_DATA[@]}"; do
    local s=${entry%%|*}
    [[ "$s" != "$session" ]] && continue
    local rest=${entry#*|}
    local wname=${rest%%|*}
    local wpath=${rest#*|}
    [[ "$wname" =~ $skip_pattern ]] && continue

    # Get branch and last commit from the pane's actual working directory
    local branch=$(git -C "$wpath" rev-parse --abbrev-ref HEAD 2>/dev/null)
    local epoch=$(git -C "$wpath" log -1 --format='%ct' 2>/dev/null)

    if [[ -n "$epoch" ]]; then
      local bdays=$(days_ago_from_epoch $epoch)
      local branch_age=$(format_age $bdays)
      local bcolor=$(staleness_color $bdays)
      print "  ${GREEN}●${RESET} ${wname}  ${bcolor}${branch_age}${RESET}"
    else
      print "  ${GREEN}●${RESET} ${wname}"
    fi
  done
}

# ── Resolve tmux session to repo path ──────────────────
session_repo_path() {
  # Find the primary pane path for this session (first window)
  local session=$1
  for entry in "${TMUX_WINDOW_DATA[@]}"; do
    local s=${entry%%|*}
    [[ "$s" != "$session" ]] && continue
    local wpath=${entry##*|}
    # Walk up to find the git root
    local candidate=$wpath
    while [[ "$candidate" != "/" ]]; do
      [[ -d "$candidate/.git" ]] && { print "$candidate"; return }
      candidate=${candidate:h}
    done
    return
  done
}

# ── Main ───────────────────────────────────────────────
main() {
  print "${DIM}loading...${RESET}"

  gather_tmux

  # Collect all repos
  local -a all_repos wp_repos
  for r in "${(@f)$(discover_repos)}"; do
    [[ -n "$r" ]] && all_repos+=("$r")
  done
  for r in "${(@f)$(discover_wp_plugins)}"; do
    [[ -n "$r" ]] && wp_repos+=("$r")
  done

  # Map tmux sessions to repo paths
  typeset -A session_to_repo  # session_name -> repo_path
  typeset -A repo_has_session # repo_path -> session_name
  local session
  for session in ${(k)TMUX_SESSIONS}; do
    [[ "$session" == _* ]] && continue  # skip utility sessions like _dotfiles
    local rpath=$(session_repo_path "$session")
    if [[ -n "$rpath" ]]; then
      session_to_repo[$session]=$rpath
      repo_has_session[$rpath]=$session
    fi
  done

  # Categorize repos
  local -a active_sessions parked_repos dormant_repos active_wp dormant_wp

  # Check main repos
  for repo in "${all_repos[@]}"; do
    if [[ -n "${repo_has_session[$repo]}" ]]; then
      active_sessions+=(${repo_has_session[$repo]})
    else
      local branches=$(repo_recent_branches "$repo" "$PARKED_THRESHOLD_DAYS")
      if [[ -n "$branches" ]]; then
        parked_repos+=("$repo")
      else
        dormant_repos+=("$repo")
      fi
    fi
  done

  # Check WP repos
  for repo in "${wp_repos[@]}"; do
    if [[ -n "${repo_has_session[$repo]}" ]]; then
      active_sessions+=(${repo_has_session[$repo]})
    else
      local last_days=$(repo_last_commit_days "$repo")
      dormant_wp+=("$repo")
    fi
  done

  # Also include tmux sessions that don't match any discovered repo
  for session in ${(k)TMUX_SESSIONS}; do
    [[ "$session" == _* ]] && continue
    if [[ -z "${session_to_repo[$session]}" ]]; then
      # Session exists but no repo found — skip or show as unlinked
      continue
    fi
    # Check if already in active_sessions
    if [[ ${active_sessions[(I)$session]} -eq 0 ]]; then
      active_sessions+=("$session")
    fi
  done

  # Deduplicate active_sessions
  active_sessions=(${(u)active_sessions})

  # Fetch night agent data
  local night_agent_data=""
  night_agent_data=$(gather_night_agent)

  # Clear loading and print header
  print "\033[A\033[K"
  print "${BOLD}───────────────── PROJECT STATUS ─────────────────${RESET}"
  print ""

  # ── Active projects ──────────────────────────────────
  for session in "${active_sessions[@]}"; do
    local repo=${session_to_repo[$session]}
    local last_days=$(repo_last_commit_days "$repo")
    local age_str=$(format_age $last_days)
    local color=$(staleness_color $last_days)

    print "${BOLD}${WHITE}${(U)session}${RESET}  ${color}last: ${age_str}${RESET}"

    get_feature_windows "$session"

    # Night agent section for eleno
    if [[ "$session" == "eleno" && -n "$night_agent_data" ]]; then
      render_night_agent "$night_agent_data"
    fi

    print ""
  done

  # ── WP Clients (without active session) ──────────────
  if (( ${#dormant_wp[@]} > 0 )); then
    print "${BOLD}${WHITE}WP-CLIENTS${RESET}"
    for repo in "${dormant_wp[@]}"; do
      local name=${repo:t}
      local last_days=$(repo_last_commit_days "$repo")
      local age_str=$(format_age $last_days)
      local color=$(staleness_color $last_days)
      local stale_mark=""
      (( last_days >= STALE_THRESHOLD_DAYS )) && stale_mark=" ${RED}⚠${RESET}"
      print "  ${name}  ${color}${age_str}${RESET}${stale_mark}"
    done
    print ""
  fi

  # ── Recently parked ──────────────────────────────────
  if (( ${#parked_repos[@]} > 0 )); then
    print "${BOLD}${WHITE}RECENTLY PARKED${RESET} ${DIM}(no tmux session, <${PARKED_THRESHOLD_DAYS}d)${RESET}"
    for repo in "${parked_repos[@]}"; do
      local name=${repo:t}
      print "  ${MAGENTA}${name}${RESET}"
      local bline
      for bline in "${(@f)$(repo_recent_branches "$repo" "$PARKED_THRESHOLD_DAYS")}"; do
        [[ -z "$bline" ]] && continue
        local branch=${bline% *}
        local days=${bline##* }
        local age_str=$(format_age $days)
        local color=$(staleness_color $days)
        print "    ${branch}  ${color}${age_str}${RESET}"
      done
    done
    print ""
  fi

  # ── Dormant ──────────────────────────────────────────
  if (( ${#dormant_repos[@]} > 0 )); then
    print "${BOLD}${WHITE}DORMANT${RESET}"
    local dormant_line="  "
    for repo in "${dormant_repos[@]}"; do
      local name=${repo:t}
      local last_days=$(repo_last_commit_days "$repo")
      local age_str=$(format_age $last_days)
      dormant_line+="${DIM}${name} ${age_str}${RESET} ${DIM}·${RESET} "
    done
    dormant_line="${dormant_line% ${DIM}·${RESET} }"
    print "$dormant_line"
    print ""
  fi
}

main
