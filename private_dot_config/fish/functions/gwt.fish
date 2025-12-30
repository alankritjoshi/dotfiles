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

    if test $clean -eq 1
        git worktree prune
    end

    mkdir -p .wt
    set -l path (realpath .wt/$branch)

    if git worktree list --porcelain | string match -q -- "worktree $path"
        cd "$path"
        return 0
    end

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

    if git show-ref --verify --quiet refs/heads/$branch
        git worktree add "$path" "$branch"; or return $status
    else
        git worktree add -b "$branch" "$path" "$base"; or return $status
    end

    cd "$path"
end
