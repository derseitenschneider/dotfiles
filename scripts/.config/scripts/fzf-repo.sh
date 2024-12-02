#!/usr/bin/env bash
if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(find ~/Notes  ~/.dotfiles ~/Repositories/work ~/Repositories/personal/ ~/Repositories/02-local/ -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _)

tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[-z $tmux_running ]]; then
  tmux new-session -s $selected_name -c $selected
  exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
  tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name

# # Check if session already exists
# # tmux has-session -t "$session_name" 2>/dev/null
# # session_exists=$?
#
# if ! tmux has-session -t "$session_name" 2> /dev/null; then
#     # Start a new session with name in detached mode
#     tmux new-session -s "$session_name" -c "$path" -d 
# fi
#
# # Attach to created session
# # tmux attach-session -t "$session_name" -c "$path"
# tmux switch-client -t "$session_name"
