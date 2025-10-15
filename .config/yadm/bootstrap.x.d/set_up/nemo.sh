#!/usr/bin/env bash

_load_dconf() {
    local dconf_file="$HOME/.config/yadm/misc/nemo/nemo-settings.dconf"
    if [[ -f "$dconf_file" ]]; then
        dconf load /org/nemo/ <"$dconf_file"
        return
    fi
    echo "nemo dconf file not found"
}

_set_up() {
    _load_dconf
    gsettings set org.nemo.preferences click-double-parent-folder true
    gsettings set org.nemo.preferences quick-renames-with-pause-in-between true
    gsettings set org.nemo.preferences thumbnail-limit 'uint64 68719476736'
    gsettings set org.nemo.preferences show-open-in-terminal-toolbar true
    gsettings set org.nemo.preferences context-menus-show-all-actions true

    gsettings set org.cinnamon.desktop.default-applications.terminal exec ghostty
    gsettings set org.cinnamon.desktop.default-applications.terminal exec-arg "-e"
}

_set_up
