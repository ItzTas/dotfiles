#!/usr/bin/env bash

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

    echo "✓ Setup completed successfully."
}

_set_up
