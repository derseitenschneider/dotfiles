#!/usr/bin/env bash
# SessionStart hook: reports a blocked dotfiles sync in every new session, on any machine.
# The marker is written and cleared by autosync/.config/scripts/dotfiles-autosync.sh.
blocked_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-sync.blocked"
[ -f "$blocked_file" ] || exit 0

details=$(cat "$blocked_file")
jq -n --arg details "$details" '{
  systemMessage: ("dotfiles sync is BLOCKED on this machine since " + $details),
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("The hourly dotfiles sync on this machine is blocked, so the dotfiles repo neither sends nor receives commits. Since:\n" + $details + "\nTell Brian at the start of your first reply and offer to resolve it. Usually a file was edited here and on another machine at the same place: rebase the local commits onto origin/main by hand, keep what Brian wants, then run the sync script (autosync/.config/scripts/dotfiles-autosync.sh in the dotfiles repo) once; a run that gets through removes the block.")
  }
}'
