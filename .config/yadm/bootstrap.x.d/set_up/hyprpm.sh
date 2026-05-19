_set_up() {
    sudo pacman -S base-devel --noconfirm
    sudo pacman -S cmake meson cpio git --noconfirm

    hyprpm update

    local plugins=(
        "https://github.com/hyprwm/hyprland-plugins"
        "https://github.com/virtcode/hypr-dynamic-cursors"
        "https://github.com/micha4w/Hypr-DarkWindow"
        "https://github.com/gfhdhytghd/hymission"
    )

    for plugin in "${plugins[@]}"; do
        yes | hyprpm add "$plugin"
    done

    local enables=(
        "dynamic-cursors"
        "Hypr-DarkWindow"
        "hyprexpo"
        "hymission"
    )

    for enable in "${enables[@]}"; do
        hyprpm enable "$enable"
    done

    hyprpm reload
}

if command -v hyprpm &>/dev/null; then
    _set_up
fi
