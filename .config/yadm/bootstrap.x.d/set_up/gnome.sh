#!/bin/env bash

_set_up() {
    dconf load / < "$HOME/.config/yadm/misc/gnome/gnome-dconf-settings.ini"
}

_set_up
