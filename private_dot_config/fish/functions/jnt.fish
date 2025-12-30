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
