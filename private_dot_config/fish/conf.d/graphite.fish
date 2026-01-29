# Graphite stack cache for starship prompt
# Updates .graphite cache file after gt commands

if not status is-interactive
    exit
end

function __graphite_update_cache --on-event fish_postexec
    # Only trigger on gt commands
    if not string match -q "gt *" "$argv"; and not test "$argv" = "gt"
        return
    end

    # On trunk branches, no stack to display
    set current_branch (git branch --show-current 2>/dev/null)
    if test "$current_branch" = "main" -o "$current_branch" = "master"
        rm -f .graphite .graphite.tmp
        return
    end

    # Update cache only if valid stack exists (has ◉ marker and >= 3 lines)
    set cmd 'gt log --stack short --reverse > .graphite.tmp 2>&1 && \
        if grep -q "◉" .graphite.tmp && [ $(wc -l < .graphite.tmp) -ge 3 ]; then \
            mv .graphite.tmp .graphite; \
        else \
            rm -f .graphite.tmp .graphite; \
        fi'

    # Branch-changing commands run synchronously for accurate prompt
    # Include short aliases: u=up, d=down, b=bottom, t=top
    if string match -qr '^gt (u|up|d|down|t|top|b|bottom|co|checkout|create|sync)' "$argv"
        bash -c "$cmd"
    else
        # Other gt commands run in background (use bash to avoid triggering shadowenv)
        bash -c "$cmd" &
        disown
    end
end
