_set_up() {
    sudo pacman -S base-devel --no-confirm
    sudo pacman -S cmake meson cpio git --no-confirm

    hyprpm update

    local plugins=(
        "https://github.com/hyprwm/hyprland-plugins"
        "https://github.com/virtcode/hypr-dynamic-cursors"
        "https://github.com/micha4w/Hypr-DarkWindow"
    )

    for plugin in "${plugins[@]}"; do
        hyprpm add "$plugin"
    done

    local enables=(
        "dynamic-cursors"
        "Hypr-DarkWindow"
        "hyprexpo"
    )

    for enable in "${enables[@]}"; do
        hyprpm enable "$enable"
    done

    hyprpm reload
}

if command -v hyprpm &>/dev/null; then
    _set_up
fi
