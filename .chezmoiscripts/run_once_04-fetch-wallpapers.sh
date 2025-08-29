#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Check if wallpapers already exist
if [ ! -d "$WALLPAPER_DIR/" ]; then
  echo "Setting up wallpapers for the first time..."

  # Run fetch-wallpapers command
  if command -v fetch-wallpapers &>/dev/null; then
    fetch-wallpapers

    # Set a random wallpaper after fetching
    if command -v random-wallpaper &>/dev/null; then
      echo "Setting initial random wallpaper..."
      random-wallpaper
    fi
  else
    echo "fetch-wallpapers command not found. Run darwin-rebuild first."
  fi
else
  echo "Wallpapers already fetched. Skipping..."
fi

