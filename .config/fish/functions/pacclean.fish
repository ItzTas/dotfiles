function pacclean
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  removes orphan packages reported by pacman -Qdtq"
        return 0
    end

    if not command -q pacman
        echo "pacman is not installed" >&2
        return 1
    end

    set -l orphans (pacman -Qdtq)

    if test -z "$orphans"
        echo "No orphan packages found."
        return
    end

    set -l valid_pkgs
    for pkg in $orphans
        if pacman -Q "$pkg" >/dev/null 2>&1
            set -a valid_pkgs "$pkg"
        end
    end

    if test (count $valid_pkgs) -eq 0
        echo "No valid orphan packages found."
    else
        sudo pacman -Rns $valid_pkgs
    end
end
