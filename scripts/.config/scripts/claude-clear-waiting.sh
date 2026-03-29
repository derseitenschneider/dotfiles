#!/usr/bin/env bash
# Clear window flag, then check if session flag should also clear
tmux set-option -w @claude-waiting 0

# If no other window in this session has @claude-waiting, clear session flag
has_waiting=$(tmux list-windows -F '#{@claude-waiting}' 2>/dev/null | grep -c '^1$')
if [ "$has_waiting" -eq 0 ]; then
    tmux set-option -s @session-claude-waiting 0
fi
