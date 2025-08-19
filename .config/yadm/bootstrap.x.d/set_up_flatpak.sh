_set_up() {
    sudo flatpak override --filesystem="$HOME"/.themes
    sudo flatpak override --filesystem="$HOME"/.icons
    sudo flatpak override --filesystem=/usr/share/themes
}

_set_up
