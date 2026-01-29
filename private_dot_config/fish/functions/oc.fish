function oc
    if command -q devx
        devx opencode $argv
    else
        opencode $argv
    end
end
