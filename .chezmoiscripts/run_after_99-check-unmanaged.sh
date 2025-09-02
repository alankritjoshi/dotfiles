#!/usr/bin/env bash

# Check for unmanaged files in tracked directories
# Runs on apply or when called directly

if [ -n "${CHEZMOI_COMMAND}" ] && [ "${CHEZMOI_COMMAND}" != "apply" ]; then
    exit 0
fi

# Get all directories managed by chezmoi
managed_dirs=$(chezmoi managed --include=dirs | cut -d'/' -f1-2 | sort -u)

if [ -z "$managed_dirs" ]; then
    exit 0
fi

has_unmanaged=false

for dir in $managed_dirs; do
    full_path="$HOME/$dir"
    if [ -d "$full_path" ]; then
        unmanaged=$(chezmoi unmanaged "$full_path" 2>/dev/null)
        if [ -n "$unmanaged" ]; then
            if [ "$has_unmanaged" = false ]; then
                echo ""
                echo "⚠️  Found unmanaged files (not tracked by chezmoi):"
                has_unmanaged=true
            fi
            echo ""
            echo "  $full_path:"
            echo "$unmanaged" | sed 's/^/    /'
        fi
    fi
done

if [ "$has_unmanaged" = true ]; then
    echo ""
    echo "Consider adding these to chezmoi or removing them if not needed."
fi