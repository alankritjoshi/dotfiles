#!/bin/bash

set -e

# Only run on personal machines (where mise is installed)
HOSTNAME=$(hostname -s)
if [[ "$HOSTNAME" != "tejas" && "$HOSTNAME" != "griha" && "$HOSTNAME" != "agrani" && "$HOSTNAME" != "trishool" ]]; then
  echo "Skipping mise install on non-personal machine"
  exit 0
fi

# Check if mise is available
if ! command -v mise &>/dev/null; then
  echo "mise not found - will be available after home-manager/darwin-rebuild completes"
  exit 0
fi

echo "Installing mise global tools..."
mise install

echo "✅ mise tools installed"
