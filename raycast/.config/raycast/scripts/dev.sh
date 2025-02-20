#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Dev
# @raycast.description Opens Chrome and Kitty with tmux for development
# @raycast.mode silent
# @raycast.packageName Development
# @raycast.icon 👨‍💻

# Switch to workspace T
aerospace workspace --fail-if-noop T 

# Open Chrome window
open -n -a "Google Chrome" --args --new-window

# Open ghostty and attach to tmux session
# If tmux session doesn't exist, it will create one
open -n -a "ghostty" 
