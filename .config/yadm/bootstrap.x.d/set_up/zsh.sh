#!/bin/env bash

_install_plugins() {
    local antidote="/usr/share/zsh-antidote/antidote.zsh"
    local bundle_file="$HOME/.config/zsh/.zsh_plugins.txt"

    if [ ! -f "$antidote" ]; then
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
    ZDOTDIR="$HOME/.config/zsh" zsh -c \
        "source '$antidote'; antidote bundle < '$bundle_file' >/dev/null"
}

_set_up() {
    _install_plugins
}

_set_up
