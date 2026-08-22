function update-minidlnad
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  syncs ~/{Musics,Pictures,Videos}/.minidlna into /opt/media and rebuilds the database"
        return 0
    end

    if not command -q minidlnad
        echo "minidlnad is not installed" >&2
        return 1
    end

    for d in Musics Pictures Videos
        set -l src "$HOME/$d/.minidlna"
        set -l dst "/opt/media/$d"

        if path is -d -- "$src"
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
