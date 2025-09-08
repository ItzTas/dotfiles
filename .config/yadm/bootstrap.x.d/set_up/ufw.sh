#!/bin/env bash

_set_up() {
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

    # sudo ufw allow ssh
    # sudo ufw allow http
    # sudo ufw allow https

    sudo ufw enable
}

_set_up "$@"
