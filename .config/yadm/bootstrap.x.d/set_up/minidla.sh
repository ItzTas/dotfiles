#!/usr/bin/env bash

_make_user_dirs() {
    local user_dirs=(
        "$HOME/Musics/.minidlna"
        "$HOME/Pictures/.minidlna"
        "$HOME/Videos/.minidlna"
    )
}

_update_file() {
    local conf="$HOME/.config/minidlna/minidlna.conf"
    local target="/etc/minidlna.conf"

    if ! sudo grep -Fxq "# DOTFILES CONFIG START" "$target"; then
        echo "→ Updating /etc/minidlna.conf with dotfiles content..."
        {
            echo ""
            echo "# DOTFILES CONFIG START"
            cat "$conf"
            echo "friendly_name=$USER"
            echo "# DOTFILES CONFIG END"
        } | sudo tee -a "$target" >/dev/null
    else
        echo "✓ /etc/minidlna.conf already contains dotfiles config."
    fi
}

_set_up() {
    sudo mkdir -p /opt/media/{Musics,Pictures,Videos}

    if ! id -u minidlna &>/dev/null; then
        echo "→ Creating system user 'minidlna'..."
        sudo useradd -r -M -d /var/lib/minidlna -s /usr/bin/nologin minidlna
    else
        echo "✓ User 'minidlna' already exists."
    fi

    sudo chown -R minidlna:minidlna /opt/media
    sudo chmod -R 755 /opt/media

    _update_file
    echo "✓ Setup completed successfully."
}

_set_up
