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
    )

    for enable in "${enables[@]}"; do
        hyprpm enable "$enable"
    done
}

_set_up
