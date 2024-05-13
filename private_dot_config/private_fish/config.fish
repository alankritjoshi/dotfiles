# set -x PATH $PATH /opt/homebrew/bin
fish_add_path /opt/homebrew/bin

set -g fish_greeting

set -gx EDITOR nvim

alias ls="eza"

# set fish_key_bindings fish_user_key_bindings

# Folders
alias d="cd ~/dev"

# Vim
alias vim="nvim"
alias v="nvim"
alias n="nvim"
alias vv="nvim ~/.config/nvim"
alias vb="nvim ~/.bootstrap"
alias vg="nvim ~/.gitconfig"
alias vf="nvim ~/.config/fish/config.fish"
alias vz="nvim ~/.config/wezterm/wezterm.lua"
alias vj="nvim ~/.config/zellij/config.kdl"
alias vs="nvim ~/.config/skhd/skhdrc"
alias vy="nvim ~/.config/yabai/yabairc"
alias vy="nvim ~/.config/yabai/yabairc"

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

# Zellij
alias j="zellij"
alias jl="zellij list-sessions"
alias jr="zellij run --"
alias jrf="zellij run -f --"
alias jal="zellij action new-tab -l .zellij/layout.kdl"
alias jad="zellij action new-tab -l ~/.zellij/layout.kdl"
alias ja="zellij attach"
alias jd="zellij delete-session"
alias jda="zellij delete-all-sessions"
alias jk="zellij kill-session"
alias jka="zellij kill-all-sessions"
alias je="zellij edit"
alias jev="zellij edit ~/.config/nvim/lua/config/lazy.lua"
alias jeb="zellij edit ~/.bootstrap/"
alias jeg="zellij edit ~/.gitconfig"
alias jef="zellij edit ~/.config/fish/config.fish"
alias jez="zellij edit ~/.config/wezterm/wezterm.lua"
alias jej="zellij edit ~/.config/zellij/config.kdl"
alias jes="zellij edit ~/.config/skhd/skhdrc"
alias jey="zellij edit ~/.config/yabai/yabairc"

# shortcuts
alias dev="cd ~/dev"
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
alias pp="poetry poe"

# other
alias dbx="databricks"

function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function web
    if test -z $argv
        echo "Usage: web <URL>"
        return 1
    end

    set url $argv[1]

    # Check if the URL starts with "http://" or "https://", and if not, add "https://"
    if not string match -q -r "https?://*" $url
        set url "https://$url"
    end

    http GET $url | textutil -convert txt -stdin -stdout
end


# check with fzf_configure_bindings -h
fzf_configure_bindings --directory=\e\cf # Alt + Ctrl + f

# Source broot bash launcher
# bass source ~/Library/Preferences/org.dystroy.broot/launcher/bash/br

# Source FZF if available
# [ -f ~/.fzf.fish ]; and source ~/.fzf.fish

# Uncomment and set up OpenSSL path if needed
# set -x PATH /usr/local/opt/openssl@3/bin $PATH

# Set up CPPFLAGS and LDFLAGS for Homebrew
set -x CPPFLAGS "-I"(brew --prefix)/include
set -x LDFLAGS "-L"(brew --prefix)/lib

zoxide init fish | source
starship init fish | source

fish_add_path $HOME/.local/bin
fish_add_path $HOME/opt/curl/bin

# for compilers to use brew curl
set -gx LDFLAGS "-L"(brew --prefix)/opt/curl/lib
set -gx CPPFLAGS "-I"(brew --prefix)/opt/curl/include
set -gx PKG_CONFIG_PATH /opt/homebrew/opt/curl/lib/pkgconfig

if status is-interactive
    # Commands to run in interactive sessions can go here
end
