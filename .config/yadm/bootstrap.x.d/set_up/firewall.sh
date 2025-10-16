#!/bin/env bash

_set_up_nftables() {
    yes | paru -S iptables-nft
}

_set_up_ufw() {
    sudo ufw disable
    sudo ufw logging full

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    local allows=()

    for arg in "$@"; do
        case "$arg" in
        --bittorrent)
            allows+=("qBittorrent")
            ;;
        --localsend)
            allows+=("53317/tcp")
            ;;
        --ssh)
            allows+=("ssh")
            ;;
        --all)
            allows+=("qBittorrent")
            allows+=("ssh")
            allows+=("53317/tcp")
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Allowed flags: 
            --bittorrent 
            --localsend"
            ;;
        esac
    done

    if [ ${#allows[@]} -eq 0 ]; then
        echo "No specific ports to allow."
    else
        for allow in "${allows[@]}"; do
            sudo ufw allow "$allow"
        done
    fi

    sudo ufw enable
    sudo systemctl enable --now ufw
}

_set_up() {
    _set_up_nftables
    _set_up_ufw "$@"
}

_set_up "$@"
