#!/bin/env bash

install_extensions() {
    local extensions_file="${XDG_CONFIG_DIR:-$HOME/.config}/yadm/gnome/extensions-list.txt"
    local failed_extensions=()

    if [ ! -f "$extensions_file" ]; then
        echo "Extensions list not found, skipping..."
        return
    fi

    while IFS= read -r ext_id; do
        [[ -z "$ext_id" || "$ext_id" =~ ^# ]] && continue

        echo "Installing and enabling extension: $ext_id"

        if ! gnome-extensions install "$ext_id" --force; then
            echo "Failed to install $ext_id"
            failed_extensions+=("$ext_id")
            continue
        fi

        if ! gnome-extensions enable "$ext_id"; then
            echo "Failed to enable $ext_id"
            failed_extensions+=("$ext_id")
            continue
        fi

    done <"$extensions_file"

    echo "All extensions from the list have been processed."

    if [ "${#failed_extensions[@]}" -gt 0 ]; then
        echo
        echo "The following extensions could not be installed or enabled:"
        for ext in "${failed_extensions[@]}"; do
            echo "  - $ext"
        done
    fi
}

_set_up() {
    if command -v gnome-extensions >/dev/null 2>&1; then
        install_extensions
    fi

    if command -v dconf >/dev/null 2>&1; then
        dconf load / <"$HOME/.config/yadm/gnome/settings.ini"
    else
        echo "dconf not found, skipping settings load."
    fi
}

_set_up
