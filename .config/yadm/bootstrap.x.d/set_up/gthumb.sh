#!/bin/env bash

_set_up() {
    dconf load /org/gnome/gthumb/ <"$HOME/.config/yadm/misc/gthumb/gthumb-settings.dconf"
}

_set_up
