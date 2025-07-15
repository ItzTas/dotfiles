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

_install_ohitstom_extensions() {
    echo ""
    echo "▶ Installing Spicetify extensions from ohitstom repository"

    local dest="$HOME/.config/spicetify/Extensions"
    mkdir -p "$dest"

    local exts=(
        "quickQueue"
        "sleepTimer"
        "volumePercentage"
        "immersiveView"
    )

    local tmpdir
    tmpdir=$(mktemp -d)

    echo "→ Cloning repository into $tmpdir"
    git clone --depth=1 "https://github.com/ohitstom/spicetify-extensions" "$tmpdir"

    echo "✔ Listing cloned content:"
    ls "$tmpdir"

    for ext in "${exts[@]}"; do
        local src="$tmpdir/$ext/$ext.js"
        local dest_file="$dest/$ext.js"
        if [ -f "$src" ]; then
            if [ -f "$dest_file" ]; then
                echo "🟡 '$ext.js' already exists in destination — skipping copy"
            else
                echo "→ Copying '$ext.js' to Extensions folder"
                cp "$src" "$dest"
            fi
            echo "→ Ensuring '$ext.js' is enabled"
            spicetify config extensions "$ext.js"
        else
            echo "⚠️ Extension '$ext.js' not found in repo at expected path: $src"
        fi
    done

    echo "🧹 Cleaning up temporary directory"
    rm -rf "$tmpdir"

    echo "✅ Done! Run 'spicetify apply' to activate changes."
}

_set_up() {
    _install_themes
    _install_ohitstom_extensions

    spicetify config current_theme Sleek color_scheme RosePine
    # spicetify config always_enable_devtools 1
    spicetify apply
}

if command -v spicetify &>/dev/null; then
    _set_up
fi
