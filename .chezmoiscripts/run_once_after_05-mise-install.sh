#!/bin/bash

set -e

HOSTNAME=$(hostname -s)
if [[ "$HOSTNAME" != "tejas" && "$HOSTNAME" != "griha" && "$HOSTNAME" != "agrani" && "$HOSTNAME" != "trishool" ]]; then
  echo "Skipping mise on non-personal machine"
  exit 0
fi

if [[ "$HOSTNAME" == "trishool" ]]; then
  sudo apt-get update
  sudo apt-get install -y libatomic1 zlib1g
fi

if ! command -v mise &>/dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "Installing mise global tools..."
mise install

echo "✅ mise installed"
