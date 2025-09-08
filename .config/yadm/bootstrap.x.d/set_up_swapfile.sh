#!/usr/bin/env bash

_is_system_encripted() {
    findmnt -no SOURCE / | grep -q '^/dev/mapper/'
}

_set_up_btrfs() {
    local size="${1:-16g}"
    if [[ -f /swap/swapfile ]]; then
        echo "Swapfile already exists at /swap/swapfile. Skipping setup."
        return 0
    fi
    if [[ ! -d /swap ]]; then
        sudo btrfs subvolume create /swap
    fi
    sudo btrfs filesystem mkswapfile --size "$size" /swap/swapfile
    sudo chmod 600 /swap/swapfile
    sudo swapon /swap/swapfile
    _activate_swapfile
}

# makes swapfile activate on boot
_activate_swapfile() {
    if _is_system_encripted; then
        grep -q "/swap/swapfile" /etc/crypttab ||
            echo "swap /swap/swapfile /dev/urandom swap,cipher=aes-xts-plain64" |
            sudo tee -a /etc/crypttab

        grep -q "/dev/mapper/swap" /etc/fstab ||
            echo "/dev/mapper/swap none swap defaults 0 0" |
            sudo tee -a /etc/fstab

        return
    fi
    grep -q "/swap/swapfile" /etc/fstab ||
        echo "/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
}

if command -v btrfs >/dev/null; then
    _set_up_btrfs "$@"
fi
