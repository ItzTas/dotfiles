_install_themes() {
    echo ""
    echo "installing spicetify themes"

    local dest="$HOME/.config/spicetify/Themes"

    local themes=(
        "Sleek"
    )

    local tmpdir
    tmpdir=$(mktemp -d)

    git clone --depth=1 "https://github.com/spicetify/spicetify-themes" "$tmpdir"

    echo "Files in the cloned output directory:"
    ls "$tmpdir"

    for theme in "${themes[@]}"; do
        local file="$tmpdir/$theme"
        echo "Copying file: $file"
        cp -r "$file" "$dest"
    done

    rm "$dest"/*/*.md "$dest"/*/*.png
}

_set_up() {
    _install_themes

    spicetify config current_theme Sleek color_scheme RosePine
    spicetify config always_enable_devtools 1
    spicetify apply
}

if command -v spicetify &>/dev/null; then
    _set_up
fi
