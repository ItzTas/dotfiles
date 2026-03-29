#!/bin/env bash

_set_up() {
    dconf load / < "$HOME/.config/yadm/gnome/settings.ini"
}

_set_up
