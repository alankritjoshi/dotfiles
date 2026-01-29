function cld
    if command -q devx
        devx claude $argv
    else
        claude $argv
    end
end
