# dotfiles (macOS)

## Steps

### Xcode

```sh
xcode-select --install
```

### [Brew](https://brew.sh/)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### [Chezmoi](https://chezmoi.io/)

#### Install

```sh
brew install chezmoi
```

#### Setup

```sh
chezmoi init git@github.com:alankritjoshi/dotfiles.git
```

> TODO: move rest of the steps to [Ansible](https://github.com/ansible/ansible) playbook which is invoked by #Chezmoi script.

### IDE

#### Install

```
brew install --cask wezterm bash fish starship nvm zellij
```

#### Change Shell

```
chsh -s $(which fish)
```

#### Install font

```
open $HOME/.config/FiraCodeNerdFontMono-Retina.ttf
```

#### Open Wezterm and Configure Fish

```
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install catppuccin/fish
fisher install edc/bass
fisher install PatrickF1/fzf.fish
```

### MacOS Tiling

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

### Tools

```
brew install fzf zoxide trash fd gnu-sed sd ripgrep bat lazygit jq httpie gh oha gum glow
```

### Languages

```
brew install pyenv node go delve
```
