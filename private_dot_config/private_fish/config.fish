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
alias b="brew"

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

# Zellij
function jn
    set -l ZJ_DIR_PATH $argv[1]
    set -l ZJ_MAYBE_LAYOUT_PATH "$ZJ_DIR_PATH/.zellij/layout.kdl"
    set -l ZJ_DIR_PATH_SPLIT (string split -r "/" $ZJ_DIR_PATH)
    set -l ZJ_DIR_NAME $ZJ_DIR_PATH_SPLIT[-1]

    if test -f $ZJ_MAYBE_LAYOUT_PATH
        gum confirm "Layout found. Create new tab with it?"
        if test $status -eq 0
            zellij action new-tab --cwd $ZJ_DIR_PATH -l $ZJ_MAYBE_LAYOUT_PATH -n $ZJ_DIR_NAME
        else
            zellij action new-pane -c -i --cwd $ZJ_DIR_PATH -- nvim
        end
    else
        zellij action new-pane -c -i --cwd $ZJ_DIR_PATH -- nvim
    end
end

function jnt
    set -l ZJ_DIR_PATH $argv[1]
    set -l ZJ_DIR_PATH_SPLIT (string split -r "/" $ZJ_DIR_PATH)
    set -l ZJ_DIR_NAME $ZJ_DIR_PATH_SPLIT[-1]

    zellij action new-tab --cwd $ZJ_DIR_PATH -l ~/.config/zellij/layouts/nvim.kdl -n $ZJ_DIR_NAME
end

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
alias jv="jn ~/.config/nvim"
alias jb="jn ~/.bootstrap"
alias jf="jn ~/.config/fish"
alias jz="jn ~/.config/wezterm"
alias jj="jn ~/.config/zellij/config.kdl"
alias js="jn ~/.config/skhd"
alias jy="jn ~/.config/yabai"
alias jg="je ~/.gitconfig"

function _attach_zellij
    set ZJ_SESSIONS (zellij list-sessions -s)
    set NO_SESSIONS (echo $ZJ_SESSIONS | tr '\n' ' ' | wc -w | tr -d '[:space:]')

    if test $NO_SESSIONS -ge 1
        zellij -l ~/.config/zellij/layouts/default.kdl -s "coding-$NO_SESSIONS"
    else
        zellij -l ~/.config/zellij/layouts/default.kdl -s coding
    end
end

function _find_and_edit_dir_with_zellij_pane
    while true
        set -l ZJ_DIR_PATH (zoxide query --interactive)
        if test $status -ne 0
            break
        else
            z $ZJ_DIR_PATH && jn $ZJ_DIR_PATH
        end
    end
end

function _find_and_edit_dir_with_zellij_tab
    while true
        set -l ZJ_DIR_PATH (zoxide query --interactive)
        if test $status -ne 0
            break
        else
            z $ZJ_DIR_PATH && jnt $ZJ_DIR_PATH
        end
    end
end

alias j _find_and_edit_dir_with_zellij_pane
alias jt _find_and_edit_dir_with_zellij_tab

set fzf_fd_opts --hidden --follow

zoxide init fish | source
starship init fish | source

fish_add_path $HOME/.local/bin
fish_add_path $HOME/opt/curl/bin

# Set up CPPFLAGS and LDFLAGS for Homebrew
set -x CPPFLAGS "-I"(brew --prefix)/include
set -x LDFLAGS "-L"(brew --prefix)/lib
set -gx LDFLAGS "-L"(brew --prefix)/opt/curl/lib
set -gx CPPFLAGS "-I"(brew --prefix)/opt/curl/include
set -gx PKG_CONFIG_PATH /opt/homebrew/opt/curl/lib/pkgconfig

if status is-interactive
    set ZELLIJ_AUTO_ATTACH true
    set ZELLIJ_AUTO_EXIT true

    if not set -q ZELLIJ
        if test "$ZELLIJ_AUTO_ATTACH" = true
            _attach_zellij
        else
            zellij -l ~/.config/zellij/layouts/default.kdl -s coding
        end

        if test "$ZELLIJ_AUTO_EXIT" = true
            kill $fish_pid
        end
    end

    j
end
