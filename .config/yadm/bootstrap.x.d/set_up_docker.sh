_set_up_docker() {
    echo "Setting up docker"

    getent group docker || sudo groupadd docker
    sudo usermod -aG docker "$USER"

    newgrp docker

    if [ -d "$HOME" ]; then
        sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
        sudo chmod g+rwx "$HOME/.docker" -R
    fi

    echo "Docker setup finished"
}

_set_up_docker
