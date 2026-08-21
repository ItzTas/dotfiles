#!/bin/env bash

ZSH_CONFIG_DIR="$HOME/.config/zsh"
ANTIDOTE_CLONE_DIR="$ZSH_CONFIG_DIR/.antidote"

# Keep this list in sync with __source_zsh_plugins in $ZSH_CONFIG_DIR/zshrc.
_find_antidote() {
    local candidates=(
        "/usr/share/zsh-antidote/antidote.zsh"
        "/usr/share/zsh/plugins/antidote/antidote.zsh"
        "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
        "$ANTIDOTE_CLONE_DIR/antidote.zsh"
    )

    local candidate
    for candidate in "${candidates[@]}"; do
        if [ -f "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done

    return 1
}

# install_packages.sh installs the zsh-antidote package, but that only covers
# Arch. Anywhere else, clone it so the zshrc has something to source.
_install_antidote() {
    if _find_antidote >/dev/null; then
        echo "antidote is already available. Skipping installation."
        return 0
    fi

    if ! command -v git &>/dev/null; then
        echo "git is not installed. Cannot clone antidote."
        return 1
    fi

    echo "Cloning antidote to $ANTIDOTE_CLONE_DIR..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_CLONE_DIR"
}

_install_plugins() {
    local antidote
    local bundle_file="$ZSH_CONFIG_DIR/.zsh_plugins.txt"

    if ! antidote=$(_find_antidote); then
        echo "antidote is not installed. Skipping zsh plugin installation."
        return
    fi

    if [ ! -f "$bundle_file" ]; then
        echo "No bundle file at $bundle_file. Skipping zsh plugin installation."
        return
    fi

    # Clone every bundle without sourcing it, so the first interactive shell
    # starts with the plugins already in $ANTIDOTE_HOME.
    echo "Installing zsh plugins with antidote..."
    ZDOTDIR="$ZSH_CONFIG_DIR" zsh -c \
        "source '$antidote'; antidote bundle < '$bundle_file' >/dev/null"
}

_set_up() {
    _install_antidote || true
    _install_plugins
}

_set_up
