#!/usr/bin/env bash

_is_system_encrypted() {
    findmnt -no SOURCE / | grep -q '^/dev/mapper/'
}

_activate_swap() {
    local swapfile="$1"
    local mapper="$2"

    if _is_system_encrypted; then
        grep -q "$swapfile" /etc/crypttab ||
            echo "swap $swapfile /dev/urandom swap,cipher=aes-xts-plain64" | sudo tee -a /etc/crypttab
        grep -q "/dev/mapper/$mapper" /etc/fstab ||
            echo "/dev/mapper/$mapper none swap defaults 0 0" | sudo tee -a /etc/fstab
        return
    fi

    grep -q "$swapfile" /etc/fstab ||
        echo "$swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
}

_set_up_btrfs_swap() {
    local size="${1:-16g}"
    local swapfile="/swap/swapfile"

    if [[ -f "$swapfile" ]]; then
        echo "Swapfile already exists at $swapfile. Skipping setup."
        return 0
    fi

    if [[ ! -d /swap ]]; then
        sudo btrfs subvolume create /swap
    fi

    sudo btrfs filesystem mkswapfile --size "$size" "$swapfile"
    sudo chmod 600 "$swapfile"
    sudo swapon "$swapfile"
    _activate_swap "$swapfile" "swap"
}

_set_up_ext_swap() {
    local size="${1:-16g}"
    local swapfile="/swapfile"

    if [[ -f "$swapfile" ]]; then
        echo "Swapfile already exists at $swapfile. Skipping setup."
        return 0
    fi

    sudo fallocate -l "$size" "$swapfile"
    sudo chmod 600 "$swapfile"
    sudo mkswap "$swapfile"
    sudo swapon "$swapfile"
    _activate_swap "$swapfile" "swap"
}

if command -v btrfs >/dev/null; then
    _set_up_btrfs_swap "$@"
else
    _set_up_ext_swap "$@"
fi
