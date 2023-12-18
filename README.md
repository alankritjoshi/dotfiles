# dotfiles

## Download

1. This will setup $HOME as a bare Git work-tree tracked inside $HOME/.dotfiles
2. Sync files from repo and replace the existing ones
3. Optionally delete old files that were replaced
4. Turn off tracking for untracked file i.e., rest of the $HOME should not show up in status

```
cd $HOME
git clone --separate-git-dir=$HOME/.dotfiles https://github.com/alankritjoshi/.dotfiles.git tmpdotfiles
rsync --recursive --verbose --exclude '.git' tmpdotfiles/ $HOME/
rm -r tmpdotfiles
git config --local status.showUntrackedFiles no
```

## Brew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## IDE

### Install

```
brew install --cask wezterm bash fish starship nvm zellij
```

### Change Shell

```
chsh -s $(which fish)
```

### Install font

```
open $HOME/.config/FiraCodeNerdFontMono-Retina.ttf
```

### Open Wezterm and Configure Fish

```
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install catppuccin/fish
fisher install edc/bass
fisher install PatrickF1/fzf.fish
```

## MacOS Tiling

```
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
yabai --start-service
skhd --start-service
```

> may require MacOS Accessibility permissions.

```
yabai --restart-service
skhd --restart-service
```

## Tools

```
brew install fzf zoxide trash fd gnu-sed sd ripgrep bat lazygit jq httpie gh oha gum glow
```

## Languages

```
brew install pyenv node go delve
```
