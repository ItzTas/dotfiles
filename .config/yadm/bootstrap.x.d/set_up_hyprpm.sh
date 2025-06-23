_set_up() {
    sudo pacman -S base-devel
    sudo pacman -S cmake meson cpio git

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

_set_up
