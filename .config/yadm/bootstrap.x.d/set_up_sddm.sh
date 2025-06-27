#!/bin/env bash

_set_up() {
    sudo mkdir -p "/etc/sddm.conf.d"

    sudo ln -fs "$HOME/.config/sddm/theme.conf" /etc/sddm.conf.d/theme.conf
    sudo ln -fs "$HOME/.config/sddm/wayland.conf.conf" /etc/sddm.conf.d/wayland.conf
}

_set_up
