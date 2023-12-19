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

