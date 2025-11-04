#!/usr/bin/env bash

_set_up() {
    dconf load /org/gnome/meld/ <"$HOME/.config/yadm/misc/meld/backup.conf"
}

_set_up
