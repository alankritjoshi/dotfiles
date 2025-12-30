function jn
    set -l ZJ_DIR_PATH $argv[1]
    set -l ZJ_MAYBE_LAYOUT_PATH "$ZJ_DIR_PATH/.zellij/layout.kdl"
    set -l ZJ_DIR_PATH_SPLIT (string split -r "/" $ZJ_DIR_PATH)
    set -l ZJ_DIR_NAME $ZJ_DIR_PATH_SPLIT[-1]

    zellij action new-pane -c -i --cwd $ZJ_DIR_PATH -- nvim
    zellij action rename-tab $ZJ_DIR_NAME
end
