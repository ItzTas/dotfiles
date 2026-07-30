#!/bin/env bash

_set_up_docker() {
    echo "Setting up docker"

    getent group docker || sudo groupadd docker
    sudo usermod -aG docker "$USER"

    if [ -d "$HOME" ]; then
        sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
        sudo chmod g+rwx "$HOME/.docker" -R
    fi

    echo "Docker setup finished"
}

_set_up_docker_credentials() {
    echo "Setting up the docker credential store"

    yes | paru -S docker-credential-secretservice

    if ! command -v docker-credential-secretservice &>/dev/null; then
        echo "docker-credential-secretservice not available, keeping the plain text store" >&2
        return
    fi

    local config="$HOME/.docker/config.json"

    mkdir -p "$(dirname "$config")"
    if [ ! -f "$config" ]; then
        echo "{}" >"$config"
    fi

    local tmp
    tmp="$(mktemp)"
    jq '.credsStore = "secretservice"' "$config" >"$tmp" && mv "$tmp" "$config"

    echo "Docker credential store setup finished"
}

_set_up_docker
_set_up_docker_credentials
