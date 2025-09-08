#!/bin/env bash

_install_plugins() {
    local plugins_dir="$HOME/.config/zsh/plugins/repos"
    mkdir -p "$plugins_dir"
    local plugins=(
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "https://github.com/zsh-users/zsh-autosuggestions.git"
        "https://github.com/zsh-users/zsh-completions"
    )

    local plugin
    for plugin in "${plugins[@]}"; do
        local plugin_name
        plugin_name=$(basename "$plugin" .git)
        local target_dir="$plugins_dir/$plugin_name"

        if [ ! -d "$target_dir/.git" ]; then
            echo "Cloning plugin: $plugin_name... → $target_dir"
            git clone "$plugin" "$target_dir" >/dev/null 2>&1 &
        else
            echo "Updating plugin: $plugin_name..."
            git -C "$target_dir" pull >/dev/null 2>&1 &
        fi
    done

    wait
}

_install_ohmyzsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
}

_set_up() {
    _install_ohmyzsh
    _install_plugins
}

_set_up
