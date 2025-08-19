#!/bin/bash

set -e

echo "Setting up nix configuration..."
# Last updated: $(date)

# Get the hostname for the configuration
HOSTNAME=$(hostname -s)
CONFIG_PATH="$HOME/.config/nix"

# Determine which flake configuration to use
if [ "$HOSTNAME" = "vanik" ]; then
    echo "Detected work laptop - using work configuration"
    FLAKE_TARGET="vanik"
elif [ "$HOSTNAME" = "tejas" ]; then
    echo "Detected personal MacBook - using personal configuration"
    FLAKE_TARGET="tejas"
elif [ "$HOSTNAME" = "griha" ]; then
    echo "Detected Mac Mini - using personal configuration"
    FLAKE_TARGET="griha"
elif [ "$HOSTNAME" = "agrani" ]; then
    echo "Detected Arch Linux desktop - using experimental configuration"
    FLAKE_TARGET="agrani"
else
    echo "Unknown hostname: $HOSTNAME - defaulting to work configuration"
    FLAKE_TARGET="vanik"
fi

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

# Determine the rebuild command based on platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    REBUILD_CMD="darwin-rebuild"
    CONFIG_TYPE="darwinConfigurations"
else
    REBUILD_CMD="nixos-rebuild"
    CONFIG_TYPE="nixosConfigurations"
fi

# Check if this is the first run
if ! command -v $REBUILD_CMD &>/dev/null; then
    echo "First time setup - building nix configuration..."
    echo ""
    echo "Note: You may be prompted for your password to activate system configuration."
    echo ""
    
    # Build and activate the configuration (will prompt for sudo password when needed)
    nix --extra-experimental-features 'nix-command flakes' build ".#${CONFIG_TYPE}.${FLAKE_TARGET}.system"
    run_darwin_rebuild sudo ./result/sw/bin/$REBUILD_CMD switch --flake ".#${FLAKE_TARGET}"
    
    echo "Nix configuration installed successfully!"
else
    echo "Nix configuration already installed, rebuilding..."
    
    # Update flake inputs and rebuild
    nix flake update
    run_darwin_rebuild sudo $REBUILD_CMD switch --flake ".#${FLAKE_TARGET}"
fi

echo "Configuration applied successfully!"
echo ""
echo "To manually rebuild in the future, run:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  sudo darwin-rebuild switch --flake ~/.config/nix"
else
    echo "  sudo nixos-rebuild switch --flake ~/.config/nix"
fi
echo ""
echo "To update packages, run:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "  nix flake update ~/.config/nix && sudo darwin-rebuild switch --flake ~/.config/nix"
else
    echo "  nix flake update ~/.config/nix && sudo nixos-rebuild switch --flake ~/.config/nix"
fi