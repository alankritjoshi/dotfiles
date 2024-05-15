#!/bin/bash

# Get the currently focused window
focused_window=$(yabai -m query --windows --window)

# Extract the application name from the focused window
app_name=$(echo "$focused_window" | jq -r '.app')

# Check if we got a valid application name
if [ -n "$app_name" ]; then
	# Use osascript to tell the application to quit
	osascript -e "tell application \"$app_name\" to quit"
else
	echo "No focused window found or failed to get application name."
fi
