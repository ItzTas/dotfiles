function setgtkicons
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <icon-theme>" \
            "  sets org.gnome.desktop.interface icon-theme"
        return 0
    end

    if not command -q gsettings
        echo "gsettings is not installed" >&2
        return 1
    end

    gsettings set org.gnome.desktop.interface icon-theme "$argv[1]"
end
