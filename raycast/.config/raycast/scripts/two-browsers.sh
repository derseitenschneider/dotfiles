#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Two Browsers
# @raycast.description Opens two Chrome windows, first with Gmail and Chat
# @raycast.mode silent
# @raycast.packageName Browser Tools
# @raycast.icon 🌐

# Open first Chrome window with Gmail and Chat in tabs
open -n -a "Google Chrome" --args --new-window "https://mail.google.com" "https://chat.google.com" "https://app.clickup.com/2154357/dashboards/21qvn-832"

# Small delay to ensure first window is created
# sleep 1

# Open second Chrome window empty
open -n -a "Google Chrome" --args --new-window
