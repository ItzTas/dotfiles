function setgtkicons
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <icon-theme>" \
        "  sets org.gnome.desktop.interface icon-theme"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    if not command -q gsettings
        echo "gsettings is not installed" >&2
        return 1
    end

    gsettings set org.gnome.desktop.interface icon-theme "$argv[1]"
end
