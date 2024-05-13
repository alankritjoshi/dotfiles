# dotfiles (macOS)

## Pre-requisites

```sh
xcode-select --install
```

## Setup with [Chezmoi](https://chezmoi.io/)

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" && ./bin/chezmoi init --apply alankritjoshi
```

> delete ./bin/chezmoi as the brew variant will be used after this point.

## Required Manual Steps

### MacOS Tiling

> run this after MacOS Accessibility permissions to yabai and skhd.

```sh
yabai --restart-service
skhd --restart-service
```

#### Enable MacOS Space movements

1. Follow guide for [Disabling System Integrity](https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection)
2. `sudo yabai --load-sa`
