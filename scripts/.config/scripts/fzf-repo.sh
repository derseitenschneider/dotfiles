#!/usr/bin/env bash
path=$(find ~ ~/.config ~/Repositories/work ~/Repositories/personal/ ~/Repositories/02-local/ -maxdepth 1 -mindepth 1 -type d | fzf)
session_name=$(basename "$path" | tr . _)


# Check if session already exists
# tmux has-session -t "$session_name" 2>/dev/null
# session_exists=$?

if ! tmux has-session -t "$session_name" 2> /dev/null; then
    # Start a new session with name in detached mode
    tmux new-session -s "$session_name" -c "$path" -d 
fi

# Attach to created session
# tmux attach-session -t "$session_name" -c "$path"
tmux switch-client -t "$session_name"
