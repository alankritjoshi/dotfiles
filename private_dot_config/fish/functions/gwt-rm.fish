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
