if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

# Raise the open-files soft limit (macOS defaults to a low 256).
ulimit -S -n 65536

# Add homebrew for GUI apps
fish_add_path /opt/homebrew/bin

set -g fish_greeting

set -gx EDITOR nvim

alias ls="eza"

# set fish_key_bindings fish_user_key_bindings

# Vim
alias vim="nvim"
alias v="nvim"
alias n="nvim"
alias nv="neovide --fork"

# Tools
alias g="git"
alias t="ls -T"
alias tt="t -L 1"
alias tta="t -L 1 -a"
alias ttl="t -L"
alias f="fzf"
alias port="lsof -i"
alias o="open"
alias c="clear"
alias e="exit"
alias gwc="g wc --format=oneline | wc -l"

# shortcuts
alias src="z ~/src"
alias cz="chezmoi"

# Useful git aliases
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gca="git commit -a"
alias gcan="git commit --amend --no-edit"
alias gcane="git commit --amend --no-edit --allow-empty"
alias gcm="git commit -m"
alias gco="git checkout"
alias gp="git push"
alias gpl="git pull"
alias gfa="git fetch --all"
alias gcl="git clone"
alias gb="git branch"
alias gg="lazygit"

# Poetry/Python
alias p="poetry"
alias pr="poetry run"
alias pv="poetry run nvim"
alias pnv="poetry run neovide --fork"
alias pp="poetry poe"

# other
alias dbx="databricks"
alias b="brew"

alias h="herdr"

set fzf_fd_opts --hidden --follow

zoxide init fish | source

starship init fish | source
enable_transience

fish_add_path $HOME/.local/bin
fish_add_path $HOME/opt/curl/bin
fish_add_path $HOME/go/bin

command -q mise && mise activate fish | source

# Source environment variables from ~/.env file
if test -f ~/.env
    # Parse and export variables from .env file
    for line in (grep -v '^#' ~/.env | grep -v '^$')
        set -l key_value (string split -m 1 '=' $line)
        if test (count $key_value) -eq 2
            set -l key $key_value[1]
            set -l value $key_value[2]
            # Remove quotes if present
            set value (string trim -c '"' $value)
            set value (string trim -c "'" $value)
            set -gx $key $value
        end
    end
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# Added by tec agent
test -x /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init && /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init fish | source
