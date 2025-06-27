#!/bin/env bash

_set_up() {
    echo "🔧 Creating /etc/sddm.conf.d directory if it doesn't exist..."
    sudo mkdir -p "/etc/sddm.conf.d"

    echo "🔗 Creating symbolic links from ~/.config/sddm/*.conf to /etc/sddm.conf.d/"
    for src in "$HOME/.config/sddm/"*.conf; do
        name=$(basename "$src")
        echo " - Linking '$src' → '/etc/sddm.conf.d/$name'"
        sudo ln -fs "$src" "/etc/sddm.conf.d/$name"
    done

    echo "✅ Symbolic links created successfully!"
}

_set_up
