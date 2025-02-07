#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Close All
# @raycast.description Closes all running applications
# @raycast.mode silent
# @raycast.packageName System
# @raycast.icon 🚫

# Get all running apps except Finder and Raycast
running_apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)')

# Close each app gracefully
for app in $running_apps; do
    # Skip Finder and Raycast
    if [[ "$app" != "Finder" && "$app" != "Raycast" && "$app" != "AeroSpace" ]]; then
        echo "Closing $app..."
        osascript -e "tell application \"$app\" to quit"
    fi
done

# Use AeroSpace to close any remaining windows
aerospace close-all-windows-but-current

echo "All applications closed!"
