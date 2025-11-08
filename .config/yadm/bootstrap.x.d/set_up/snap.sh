#!/usr/bin/env bash

_set_up() {
    sudo systemctl enable --now snapd.socket
    sudo ln -s /var/lib/snapd/snap /snap
}

_set_up
