#!/bin/bash
if [ ! -f ~/.config/chezmoi/key.txt ]; then
  echo "Decrypting rage identity key (one-time setup)..."
  mkdir -p ~/.config/chezmoi
  rage -d ~/.local/share/chezmoi/key.txt.age > ~/.config/chezmoi/key.txt
  chmod 600 ~/.config/chezmoi/key.txt
fi