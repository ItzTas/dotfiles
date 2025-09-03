#!/bin/env bash

_install_plugins() {
    plugins=(
        "https://github.com/zsh-users/zsh-syntax-highlighting.git"
        "https://github.com/zsh-users/zsh-autosuggestions.git"
    )

    for plugin in "${plugins[@]}"; do
        plugin_name=$(basename "$plugin" .git)
        target_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"

        if [ ! -d "$target_dir" ]; then
            git clone "$plugin" "$target_dir"
        else
            echo "Plugin $plugin_name already installed"
        fi
    done
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
