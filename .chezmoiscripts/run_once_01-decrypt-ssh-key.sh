#!/bin/bash

# Only decrypt SSH key if it doesn't already exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "Decrypting SSH key..."
  chezmoi age decrypt --passphrase ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519.age > "$HOME/.ssh/id_ed25519"
  chmod 600 "$HOME/.ssh/id_ed25519"
  echo "SSH key installed successfully"
else
  echo "SSH key already exists, skipping decryption"
fi