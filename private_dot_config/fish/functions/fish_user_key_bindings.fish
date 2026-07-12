function fish_user_key_bindings
    # fish_vi_key_bindings
    # fzf_key_bindings

    # check with fzf_configure_bindings -h
    fzf_configure_bindings --directory=\e\cf # Alt + Ctrl + f

    # bind yy fish_clipboard_copy
    # bind Y fish_clipboard_copy


    bind --erase --mode default --preset \cl
    bind --erase --mode insert --preset \cl
    bind --erase --mode visual --preset \cl
end
