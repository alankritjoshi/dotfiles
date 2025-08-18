#!/bin/bash

set -e

echo "Setting up nix-darwin configuration..."
# Last updated: $(date)

# Get the hostname for the configuration
HOSTNAME=$(hostname -s)
CONFIG_PATH="$HOME/.config/nix-darwin"

# Ensure we're in the right directory
cd "$CONFIG_PATH"

# Function to run darwin-rebuild with automatic conflict resolution
run_darwin_rebuild() {
    # First attempt
    output=$("$@" 2>&1) && {
        echo "$output"
        return 0
    } || {
        echo "$output"
        
        # If there are /etc conflicts, handle them and retry once
        if echo "$output" | grep -q "Unexpected files in /etc"; then
            echo "Moving conflicting /etc files..."
            echo "$output" | grep "^  /" | sed 's/^  //' | while read -r file; do
                [ -f "$file" ] && sudo mv "$file" "${file}.before-nix-darwin"
            done
            
            # Retry once after moving files
            "$@"
        else
            return 1
        fi
    }
}

# Check if this is the first run
if ! command -v darwin-rebuild &>/dev/null; then
    echo "First time setup - building nix-darwin..."
    echo ""
    echo "Note: You may be prompted for your password to activate system configuration."
    echo ""
    
    # Build and activate the configuration (will prompt for sudo password when needed)
    nix --extra-experimental-features 'nix-command flakes' build ".#darwinConfigurations.${HOSTNAME}.system"
    run_darwin_rebuild sudo ./result/sw/bin/darwin-rebuild switch --flake ".#${HOSTNAME}"
    
    echo "nix-darwin installed successfully!"
else
    echo "nix-darwin already installed, rebuilding configuration..."
    
    # Update flake inputs and rebuild
    nix flake update
    run_darwin_rebuild sudo darwin-rebuild switch --flake ".#${HOSTNAME}"
fi

echo "Configuration applied successfully!"
echo ""
echo "To manually rebuild in the future, run:"
echo "  sudo darwin-rebuild switch --flake ~/.config/nix-darwin"
echo ""
echo "To update packages, run:"
echo "  nix flake update ~/.config/nix-darwin && sudo darwin-rebuild switch --flake ~/.config/nix-darwin"