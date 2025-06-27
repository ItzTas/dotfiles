_set_up() {
    sudo pacman -S base-devel
    sudo pacman -S cmake meson cpio git

    hyprpm update

    local plugins=(
        "https://github.com/hyprwm/hyprland-plugins"
        "https://github.com/virtcode/hypr-dynamic-cursors"
    )

    for plugin in "${plugins[@]}"; do
        hyprpm add "$plugin"
    done

    local enables=(
        "dynamic-cursors"
        "Hypr-DarkWindow"
    )

    for enable in "${enables[@]}"; do
        hyprpm enable "$enable"
    done

    hyprpm reload
}

if command -v hyprpm &>/dev/null; then
    _set_up
fi
