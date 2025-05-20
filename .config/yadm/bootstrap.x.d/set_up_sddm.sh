#!/bin/env bash

_set_up() {
    sudo mkdir -p "/etc/sddm.conf.d"

    sudo ln -s "$HOME/.config/sddm.my/theme.conf" /etc/sddm.conf.d/theme.conf
    sudo ln -s "$HOME/.config/sddm.my/wayland.conf.conf" /etc/sddm.conf.d/wayland.conf
}

_set_up
