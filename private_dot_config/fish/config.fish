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
function d
    if test (count $argv) -eq 0
        fd -t d | fzf
    else
        set depth $argv[1]
        fd -t d -d $depth | fzf
    end
end

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

    zellij action new-pane -c -i --cwd $ZJ_DIR_PATH -- nvim
    zellij action rename-tab $ZJ_DIR_NAME
end

function jnt
    set -l ZJ_DIR_PATH $argv[1]
    set -l ZJ_MAYBE_LAYOUT_PATH "$ZJ_DIR_PATH/.zellij/layout.kdl"
    set -l ZJ_DIR_PATH_SPLIT (string split -r "/" $ZJ_DIR_PATH)
    set -l ZJ_DIR_NAME $ZJ_DIR_PATH_SPLIT[-1]

    if test -f $ZJ_MAYBE_LAYOUT_PATH
        zellij action new-tab --cwd $ZJ_DIR_PATH -l $ZJ_MAYBE_LAYOUT_PATH -n $ZJ_DIR_NAME
    else
        zellij action new-tab --cwd $ZJ_DIR_PATH -l ~/.config/zellij/layouts/nvim.kdl -n $ZJ_DIR_NAME
    end

    zellij action rename-tab $ZJ_DIR_NAME
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
alias jv="je ~/.config/nvim"
alias jb="je ~/.bootstrap"
alias jf="je ~/.config/fish/config.fish"
alias jz="je ~/.config/wezterm/wezterm.lua"
alias jc="je ~/.config/zellij/config.kdl"
alias jt="je ~/.config/aerospace/aerospace.toml"
alias jg="je ~/.gitconfig"
alias j="ja || zellij -l ~/.config/zellij/layouts/default.kdl"

function _find_and_edit_dir_with_zellij_pane
    while true
        set -l ZJ_DIR_PATH (zoxide query --list | fzf)
        if test $status -ne 0
            break
        else
            z $ZJ_DIR_PATH && jn $ZJ_DIR_PATH
        end
    end
end

function _find_and_edit_dir_with_zellij_tab
    while true
        set -l ZJ_DIR_PATH (zoxide query --list | fzf)
        if test $status -ne 0
            break
        else
            z $ZJ_DIR_PATH && jnt $ZJ_DIR_PATH
        end
    end
end

alias s _find_and_edit_dir_with_zellij_pane
alias st _find_and_edit_dir_with_zellij_tab

set fzf_fd_opts --hidden --follow

zoxide init fish | source

function starship_transient_prompt_func
    starship module character
end
starship init fish | source
enable_transience

fish_add_path $HOME/.local/bin
fish_add_path $HOME/opt/curl/bin
fish_add_path $HOME/go/bin
fish_add_path /opt/homebrew/opt/python@3.11/libexec/bin

# Added by Windsurf
fish_add_path /Users/alankritjoshi/.codeium/windsurf/bin

# Set up CPPFLAGS and LDFLAGS for Homebrew
set -x CPPFLAGS "-I"(brew --prefix)/include
set -x LDFLAGS "-L"(brew --prefix)/lib
set -gx LDFLAGS "-L"(brew --prefix)/opt/curl/lib
set -gx CPPFLAGS "-I"(brew --prefix)/opt/curl/include
set -gx PKG_CONFIG_PATH /opt/homebrew/opt/curl/lib/pkgconfig

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

function gwt --description "Create/open a git worktree under .wt/<branch> and cd into it. --clean prunes stale worktrees and removes stale target dir."
    set -l clean 0
    set -l args $argv

    if test (count $args) -ge 1; and test "$args[1]" = --clean
        set clean 1
        set args $args[2..-1]
    end

    set -l branch $args[1]
    set -l base (test -n "$args[2]"; and echo $args[2]; or echo origin/main)

    if test -z "$branch"
        echo "usage: gwt [--clean] <branch> [base]"
        return 1
    end

    # Prune stale worktree records first (only when requested)
    if test $clean -eq 1
        git worktree prune
    end

    mkdir -p .wt
    set -l path (realpath .wt/$branch)

    # If already a registered worktree, just cd into it
    if git worktree list --porcelain | string match -q -- "worktree $path"
        cd "$path"
        return 0
    end

    # Path exists but is not registered as a worktree => stale folder
    if test -e "$path"
        if test $clean -eq 1
            echo "gwt: removing stale dir '$path' (not a registered worktree)"
            rm -rf "$path"; or return $status
        else
            echo "gwt: '$path' already exists but is not registered as a git worktree."
            echo "Tip: re-run with --clean, or inspect with: git worktree list"
            return 1
        end
    end

    # Create/attach worktree
    if git show-ref --verify --quiet refs/heads/$branch
        git worktree add "$path" "$branch"; or return $status
    else
        git worktree add -b "$branch" "$path" "$base"; or return $status
    end

    cd "$path"
end

function gwt-rm --description "Remove git worktree at .wt/<branch> (does NOT delete branch). Flags: --force, --prune"
    set -l force 0
    set -l prune 0
    set -l args

    for a in $argv
        switch $a
            case --force -f
                set force 1
            case --prune -p
                set prune 1
            case '*'
                set -a args $a
        end
    end

    set -l branch $args[1]
    if test -z "$branch"
        echo "usage: gwt-rm [--force|-f] [--prune|-p] <branch>"
        return 1
    end

    set -l path (realpath .wt/$branch 2>/dev/null)
    if test -z "$path"
        set path (pwd)/.wt/$branch
    end

    if git worktree list --porcelain | string match -q -- "worktree $path"
        if test $force -eq 1
            git worktree remove --force "$path"; or return $status
        else
            git worktree remove "$path"; or return $status
        end
    else
        echo "gwt-rm: '$path' is not a registered worktree."
        echo "Run: git worktree list"
        return 1
    end

    if test $prune -eq 1
        git worktree prune
    end
end

test -x /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init && /Users/alankritjoshi/.local/state/tec/profiles/base/current/global/init fish | source

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
