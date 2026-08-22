function millennium_skin_add
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <skin-url>" \
            "  adds the skin repository as a yadm submodule under the Steam skins directory"
        return 0
    end

    if not command -q yadm
        echo "yadm is not installed" >&2
        return 1
    end

    set -l skins_dir "$HOME/.local/share/Steam/steamui/skins"
    mkdir -p "$skins_dir"

    if not path is -d -- "$skins_dir"
        echo "Directory not found: $skins_dir"
        return 1
    end

    pushd "$skins_dir"; or return 1
    echo "Adding plugin submodule..."
    yadm submodule add "$argv[1]"
    popd
end
