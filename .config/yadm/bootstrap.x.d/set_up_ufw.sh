_set_up() {
    sudo ufw logging medium

    sudo ufw default deny incoming
    sudo ufw default allow outgoing

    # sudo ufw allow ssh
    # sudo ufw allow http
    # sudo ufw allow https

    sudo ufw enable
}

_set_up
