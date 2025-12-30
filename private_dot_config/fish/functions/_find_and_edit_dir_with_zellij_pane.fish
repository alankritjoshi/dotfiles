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
