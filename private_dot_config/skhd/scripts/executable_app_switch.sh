#!/bin/bash

APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
	echo "Usage: $0 <Application Name>"
	exit 1
fi

# Check if the application is running
if osascript -e "application \"$APP_NAME\" is running" | grep -q "true"; then
	# If running, use yabai to focus it
	window_id=$(yabai -m query --windows | jq -r --arg APP_NAME "$APP_NAME" '.[] | select(.app == $APP_NAME) | .id' | head -n 1)
	if [ -n "$window_id" ]; then
		yabai -m window --focus "$window_id"
	else
		echo "$APP_NAME is running but no window found."
	fi
else
	# If not running, open it
	open -a "$APP_NAME"
fi
