_set_up() {
    sudo ufw logging full

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    local allows=(
        "qBittorrent"
    )

    for allow in "${allows[@]}"; do
        sudo ufw allow "$allow"
    done

    # sudo ufw allow ssh
    # sudo ufw allow http
    # sudo ufw allow https

    sudo ufw enable
}

_set_up
