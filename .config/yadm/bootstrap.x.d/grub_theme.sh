_change_grub_theme() {
    THEME_PATH="/boot/grub/themes/elegant-mojave"
    GRUB_CONFIG="/etc/default/grub"
    THEME_LINE='GRUB_THEME="/boot/grub/themes/elegant-mojave/theme.txt"'

    if grep -qF "$THEME_LINE" "$GRUB_CONFIG"; then
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

_change_grub_theme
