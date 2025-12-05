#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Dev
# @raycast.description Opens Chrome and Kitty with tmux for development
# @raycast.mode silent
# @raycast.packageName Development
# @raycast.icon 👨‍💻

# Open Chrome window
open -n -a "Google Chrome" --args --new-window --incognito
raycast windows left half

# Open ghostty 
open -n -a "ghostty" 
raycast windows right half
