_set_up() {
    local sources=(
        "https://flathub.org/repo/flathub.flatpakrepo"
    )

    for source in "${sources[@]}"; do
        flatpak remote-add --if-not-exists "$(basename "$source" .flatpakrepo)" "$source"
    done
}

_set_up
