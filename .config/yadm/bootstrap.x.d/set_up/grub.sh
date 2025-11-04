#!/bin/env bash

_change_grub_theme() {
    if ! command -v grub-mkconfig &>/dev/null; then
        echo "GRUB is not installed. Skipping theme configuration..."
        return
    fi

    local GRUB_CONFIG="/etc/default/grub"
    if [[ ! -f "$GRUB_CONFIG" ]]; then
        echo "GRUB configuration file not found. Skipping..."
        return
    fi

    if [[ ! -d "/boot/grub" ]]; then
        echo "GRUB does not appear to be the system bootloader. Skipping..."
        return
    fi

    local THEME_PATH
    THEME_PATH="/boot/grub/themes/elegant-mojave"
    local GRUB_CONFIG
    GRUB_CONFIG="/etc/default/grub"
    local THEME_LINE
    THEME_LINE='GRUB_THEME="/boot/grub/themes/elegant-mojave/theme.txt"'

    if grep -q "$THEME_LINE" "$GRUB_CONFIG"; then
        echo "GRUB theme is already set. Skipping..."
        return
    fi

    if [[ ! -d "$THEME_PATH" ]]; then
        echo "Copying GRUB theme..."
        sudo cp -r "$HOME/.config/grubthemes/Elegant-mojave-window-grub-themes/left-dark-1080p" "$THEME_PATH"
    fi

    echo "Setting GRUB theme..."
    echo "$THEME_LINE" | sudo bash -c 'cat >> /etc/default/grub'

    echo "Updating GRUB configuration..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

_set_up() {
    _change_grub_theme
}

# _set_up
