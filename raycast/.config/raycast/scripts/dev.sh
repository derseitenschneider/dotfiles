#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Dev
# @raycast.description Opens Chrome and Kitty with tmux for development
# @raycast.mode silent
# @raycast.packageName Development
# @raycast.icon 👨‍💻

# Open Chrome window
open -n -a "Google Chrome" --args --new-window

# Open Kitty and attach to tmux session
# If tmux session doesn't exist, it will create one
open -n -a "kitty" --args tmux a || tmux new-session
