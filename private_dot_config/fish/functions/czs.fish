function czs --wraps chezmoi --description "chezmoi (shopify instance)"
    chezmoi --config ~/.config/chezmoi-shopify.yaml $argv
end
