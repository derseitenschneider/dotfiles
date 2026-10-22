#!/usr/bin/env bash
# SessionStart hook: reports a blocked dotfiles-autopull (devserver) in every new
# session. The marker is written and cleared by ~/.local/bin/dotfiles-autopull;
# machines without it (the Mac) print nothing.
blocked_file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-autopull.blocked"
[ -f "$blocked_file" ] || exit 0

details=$(cat "$blocked_file")
jq -n --arg details "$details" '{
  systemMessage: ("dotfiles-autopull is BLOCKED on this machine since " + $details),
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: ("dotfiles-autopull on this machine is blocked, so ~/dotfiles no longer receives commits from origin. Since:\n" + $details + "\nTell Brian at the start of your first reply and offer to resolve it: local edits in ~/dotfiles collide with incoming commits; get them into origin via the Mac (it is the only machine that pushes) or drop them if origin already has them, then run ~/.local/bin/dotfiles-autopull.")
  }
}'
