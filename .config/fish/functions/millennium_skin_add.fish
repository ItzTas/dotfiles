function millennium_skin_add
    set -l skins_dir "$HOME/.local/share/Steam/steamui/skins"
    mkdir -p "$skins_dir"

    if test -z "$argv[1]"
        echo "Usage: "(status current-function)" <skin-url>"
        return 1
    end

    if not test -d "$skins_dir"
        echo "Directory not found: $skins_dir"
        return 1
    end

    pushd "$skins_dir"; or return 1
    echo "Adding plugin submodule..."
    yadm submodule add "$argv[1]"
    popd
end
