_set_up_gtk_theme() {
    mkdir -p "$HOME/.themes"
    mkdir -p "$HOME/.icons"

    sudo cp -r /usr/share/themes/catppuccin-mocha-lavender-standard+default "$HOME/.themes"
    sudo cp -r /usr/share/icons/candy-icons "$HOME/.icons"

    flatpak override --user --filesystem="$HOME/.themes"
    flatpak override --user --filesystem="$HOME/.icons"

    flatpak override --user --env=GTK_THEME=catppuccin-mocha-lavender-standard+default
    flatpak override --user --env=ICON_THEME=candy-icons
}

_set_up_qt6_theme() {
    flatpak override --user --env=QT_QPA_PLATFORMTHEME=qt6ct
    flatpak override --user --filesystem="$HOME/.config/qt6ct"
}

_set_up() {
    _set_up_gtk_theme
    _set_up_qt6_theme
}

_set_up
