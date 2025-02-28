#!/bin/bash

# Required Raycast metadata
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title SSH Vim Tmux
# @raycast.mode fullOutput
# @raycast.packageName Development
# @raycast.icon 💻

# Configuration
SSH_HOST="entwicklung"
INSTANCE="hsb"
REMOTE_PATH="www/$INSTANCE.entwicklung.xyz/public_html/wp-content/themes/morntag-hello-elementor-1.5.2"
TMUX_SESSION="ssh-entwicklung-${INSTANCE}"
GHOSTTY_TERMINAL="ghostty"

# Check if tmux is running
if command -v tmux &> /dev/null; then
  if tmux ls | grep -q "$TMUX_SESSION"; then
    # Session exists, attach to it
    TMUX_COMMAND="tmux attach-session -t $TMUX_SESSION"
  else
    # Session doesn't exist, create and attach
    TMUX_COMMAND="tmux new-session -ds $TMUX_SESSION"
  fi
else
  echo "tmux not found. Using regular SSH."
  TMUX_COMMAND="" # No tmux command
fi

# Construct the SSH command with vim and desired settings
SSH_COMMAND="ssh $SSH_HOST 'cd \"$REMOTE_PATH\"; vim +\"set nu rnu | Explore\"; bash'"

# # Construct the final command
# if [ -n "$TMUX_COMMAND" ]; then
#   FINAL_COMMAND="$TMUX_COMMAND ';' $SSH_COMMAND"
# else
#   FINAL_COMMAND="$SSH_COMMAND"
# fi
FINAL_COMMAND=$SSH_COMMAND

# Execute the command in Ghosty
open -na ghostty --args --working-directory="$REMOTE_PATH" -e "$FINAL_COMMAND"
# Optional: Add error handling
if [ $? -ne 0 ]; then
  echo "Error executing command."
  exit 1
fi

echo "Command executed successfully."

exit 0
