#!/bin/bash

set -e

echo "Setting up nix-darwin configuration..."
# Last updated: $(date)

# Get the hostname for the configuration
HOSTNAME=$(hostname -s)
CONFIG_PATH="$HOME/.config/nix-darwin"

# Ensure we're in the right directory
cd "$CONFIG_PATH"

# Function to handle /etc file conflicts
handle_etc_conflicts() {
    local output="$1"
    
    # Check if the error is about unexpected files in /etc
    if echo "$output" | grep -q "Unexpected files in /etc"; then
        echo "Detected conflicting files in /etc, automatically handling..."
        
        # Extract file paths from the error message
        files=$(echo "$output" | grep "^  /" | sed 's/^  //')
        
        for file in $files; do
            if [ -f "$file" ]; then
                echo "Backing up $file to ${file}.before-nix-darwin"
                sudo mv "$file" "${file}.before-nix-darwin"
            fi
        done
        
        return 0
    fi
    
    return 1
}

# Function to run darwin-rebuild with automatic conflict resolution
run_darwin_rebuild() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Running darwin-rebuild (attempt $attempt/$max_attempts)"
        
        # Capture both stdout and stderr, run the command that was passed as arguments
        output=$("$@" 2>&1) && {
            echo "$output"
            return 0
        } || {
            echo "$output"
            
            # Check if it's an /etc conflict error
            if handle_etc_conflicts "$output"; then
                echo "Retrying after handling conflicts..."
                attempt=$((attempt + 1))
                continue
            else
                # Some other error occurred
                return 1
            fi
        }
    done
    
    echo "Failed after $max_attempts attempts"
    return 1
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