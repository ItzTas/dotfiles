#!/usr/bin/env bash

_set_up() {
    sudo mkdir -p /var/lib/minidlna/{music,pictures,videos}
    sudo mkdir -p /var/log/minidlna

    if ! id -u minidlna &>/dev/null; then
        echo "→ Creating system user 'minidlna'..."
        sudo useradd -r -M -d /var/lib/minidlna -s /usr/bin/nologin minidlna
    else
        echo "✓ User 'minidlna' already exists."
    fi

    sudo chown -R minidlna:minidlna /var/lib/minidlna
    sudo chown -R minidlna:minidlna /var/log/minidlna

    echo "✓ Setup completed successfully."
}

_set_up
