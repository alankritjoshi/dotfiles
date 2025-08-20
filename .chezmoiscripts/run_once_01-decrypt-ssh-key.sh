#!/bin/bash

# Get the hostname to determine which key to decrypt
HOSTNAME=$(hostname -s)

# Map hostname to machine name
case "$HOSTNAME" in
  "Alankrits-MacBook-Pro")
    MACHINE="vanik"
    ;;
  *)
    # Use hostname as machine name for others
    MACHINE="$HOSTNAME"
    ;;
esac

# Check if machine-specific encrypted key exists
ENCRYPTED_KEY="$HOME/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519_${MACHINE}.age"

if [ ! -f "$ENCRYPTED_KEY" ]; then
  echo "⚠️  No encrypted SSH key found for machine: $MACHINE"
  echo "Expected file: $ENCRYPTED_KEY"
  echo ""
  echo "Available encrypted keys:"
  ls -la ~/.local/share/chezmoi/.chezmoiencrypted/encrypted_private_id_ed25519_*.age 2>/dev/null || echo "None found"
  exit 0
fi

# Only decrypt SSH key if it doesn't already exist
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  echo "SSH key not found, decrypting $MACHINE-specific key from age-encrypted file"
  
  # Create a temporary file
  TEMP_KEY=$(mktemp)
  
  # Decrypt to temp file - passphrase prompt will go to terminal
  if chezmoi age decrypt --passphrase "$ENCRYPTED_KEY" --output "$TEMP_KEY"; then
    # Validate the key
    if head -n 1 "$TEMP_KEY" | grep -q "BEGIN.*PRIVATE KEY"; then
      mv "$TEMP_KEY" "$HOME/.ssh/id_ed25519"
      chmod 600 "$HOME/.ssh/id_ed25519"
      echo "✅ SSH key for $MACHINE decrypted and installed successfully"
      
      # Also copy the corresponding public key
      PUB_KEY="$HOME/.local/share/chezmoi/private_dot_ssh/id_ed25519_${MACHINE}.pub"
      if [ -f "$PUB_KEY" ]; then
        cp "$PUB_KEY" "$HOME/.ssh/id_ed25519.pub"
        chmod 644 "$HOME/.ssh/id_ed25519.pub"
        echo "✅ Public key copied"
      fi
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