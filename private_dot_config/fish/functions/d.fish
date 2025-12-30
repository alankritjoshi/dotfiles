function d
    if test (count $argv) -eq 0
        set dir (fd -t d | fzf)
    else
        set depth $argv[1]
        set dir (fd -t d -d $depth | fzf)
    end

    if test -n "$dir"
        cd "$dir"
    end
end
