if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

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
alias dev="z ~/dev"
alias src="z ~/src"
alias cz="chezmoi"
alias a="aerospace"

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

# Zellij
alias jl="zellij list-sessions"
alias jr="zellij run --"
alias jrf="zellij run -f --"
alias jal="zellij action new-tab -l .zellij/layout.kdl"
alias ja="zellij attach"
alias jd="zellij delete-session"
alias jda="zellij delete-all-sessions"
alias jk="zellij kill-session"
alias jka="zellij kill-all-sessions"
alias je="zellij edit -i"
alias jv="je ~/.config/nvim"
alias jb="je ~/.bootstrap"
alias jf="je ~/.config/fish/config.fish"
alias jc="je ~/.config/zellij/config.kdl"
alias jt="je ~/.config/aerospace/aerospace.toml"
alias jg="je ~/.gitconfig"
alias j="ja || zellij -l ~/.config/zellij/layouts/default.kdl"

alias s _find_and_edit_dir_with_zellij_pane
alias st _find_and_edit_dir_with_zellij_tab

set fzf_fd_opts --hidden --follow

zoxide init fish | source

starship init fish | source
enable_transience

fish_add_path $HOME/.local/bin
fish_add_path $HOME/opt/curl/bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/opt/python@3.11/libexec/bin

# Added by Windsurf
fish_add_path /Users/alankritjoshi/.codeium/windsurf/bin

# if status is-interactive
#     set ZELLIJ_AUTO_ATTACH true
#     set ZELLIJ_AUTO_EXIT true
#
#     if not set -q ZELLIJ
#         if test "$ZELLIJ_AUTO_ATTACH" = true
#             j
#         end
#
#         if test "$ZELLIJ_AUTO_EXIT" = true
#             kill $fish_pid
#         end
#     end
# end

if test -f /opt/dev/dev.fish
    source /opt/dev/dev.fish
end

alias cld claude
alias cdx codex
alias oc opencode

test -x /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init && /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init fish | source

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
