#!/bin/env bash

_set_up_nftables() {
    yes | paru -S iptables
}

_set_up_ufw() {
    sudo ufw disable
    sudo ufw logging full

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    sudo ufw enable
    sudo systemctl enable --now ufw
}

_set_up() {
    _set_up_nftables
    _set_up_ufw "$@"
}

_set_up "$@"
