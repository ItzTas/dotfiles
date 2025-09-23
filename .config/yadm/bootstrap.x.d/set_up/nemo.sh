#!/bin/env bash

_set_preference() {
    gsettings set org.nemo.preferences "$1" "$2"
}

_load_dconf() {
    local dconf_file="$HOME/.config/yadm/misc/nemo/nemo-settings.dconf"
}

_set_up() {
    _set_preference click-double-parent-folder true
    _set_preference quick-renames-with-pause-in-between true
    _set_preference thumbnail-limit 'uint64 68719476736'
    _set_preference show-open-in-terminal-toolbar true
    _set_preference context-menus-show-all-actions true

    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
    gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg "-e"
}

_set_up
