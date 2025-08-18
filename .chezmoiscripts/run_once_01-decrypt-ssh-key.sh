#!/bin/bash

# Only decrypt SSH key if it doesn't already exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "SSH key not found, need to decrypt it from age-encrypted file"
  
  # Create a temporary file
  TEMP_KEY=$(mktemp)
  
  # Decrypt to temp file - passphrase prompt will go to terminal
  # We need to ensure the prompt doesn't go to the file
  if chezmoi age decrypt --passphrase ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519.age --output "$TEMP_KEY"; then
    # Validate the key
    if head -n 1 "$TEMP_KEY" | rg -q "BEGIN.*PRIVATE KEY"; then
      mv "$TEMP_KEY" "$HOME/.ssh/id_ed25519"
      chmod 600 "$HOME/.ssh/id_ed25519"
      echo "✅ SSH key decrypted and installed successfully"
    else
      echo "❌ Decryption produced invalid SSH key content"
      echo "Debug: First line of decrypted content:"
      head -n 1 "$TEMP_KEY"
      rm -f "$TEMP_KEY"
      exit 1
    fi
  else
    echo "❌ Failed to decrypt SSH key. Wrong passphrase?"
    rm -f "$TEMP_KEY"
    exit 1
  fi
else
  echo "SSH key already exists, skipping decryption"
fi