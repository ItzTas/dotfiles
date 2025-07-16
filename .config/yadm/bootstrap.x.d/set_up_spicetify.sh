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

_install_spicetify_extension() {
    local repo_url="$1"
    local exts=("${@:2}")
    local dest="$HOME/.config/spicetify/Extensions"
    mkdir -p "$dest"

    local tmpdir
    tmpdir=$(mktemp -d)

    echo "→ Cloning repository into $tmpdir"
    git clone --depth=1 "$repo_url" "$tmpdir"

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

_install_spicetify_extensions() {
    ohitstom_exts=(
        "scannables"
        "tracksToEdges"
        "quickQueue"
        "sleepTimer"
        "volumePercentage"
        "immersiveView"
    )

    rxri_exts=(
        "featureshuffle"
        "songstats"
        "wikify"
        "writeify"
    )

    huhridge_exts=(
        "goToSong"
        "listPlaylistsWithSong"
        "playlistIntersection"
        "skipStats"
    )

    _install_spicetify_extension "https://github.com/ohitstom/spicetify-extensions" "${ohitstom_exts[@]}"
    _install_spicetify_extension "https://github.com/rxri/spicetify-extensions" "${rxri_exts[@]}"
    _install_spicetify_extension "https://github.com/huhridge/huh-spicetify-extensions" "${huhridge_exts[@]}"
}

_set_up() {
    _install_spicetify_extensions

    spicetify config current_theme Sleek color_scheme RosePine
    spicetify config always_enable_devtools 1
    spicetify config sidebar_config 0
    spicetify apply
}

if command -v spicetify &>/dev/null; then
    _set_up
fi
