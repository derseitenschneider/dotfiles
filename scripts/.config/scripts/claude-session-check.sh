#!/usr/bin/env bash
# Check if a session has any window with @claude-waiting set
# Returns "1" if waiting, empty if not
tmux list-windows -t "$1" -F '#{@claude-waiting}' 2>/dev/null | grep -q '^1$' && printf '1'
