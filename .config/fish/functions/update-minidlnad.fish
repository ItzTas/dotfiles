function update-minidlnad
    if not command -q minidlnad
        echo "minidlnad is not installed" >&2
        return 1
    end

    for d in Musics Pictures Videos
        set -l src "$HOME/$d/.minidlna"
        set -l dst "/opt/media/$d"

        if test -d "$src"
            echo "→ Copying $src to $dst..."
            sudo cp -r "$src/." "$dst/"
            sudo chown -R minidlna:minidlna "$dst"
        else
            echo "⚠️  Source directory $src does not exist, skipping."
        end
    end

    echo "→ Rebuilding MiniDLNA database..."
    sudo minidlnad -R

    echo "✓ Update completed."
end
