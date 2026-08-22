function save_gnome
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  dumps dconf and the enabled GNOME extensions into \$XDG_CONFIG_HOME/yadm/gnome"
        return 0
    end

    if not command -q dconf
        echo "dconf is not installed" >&2
        return 1
    end

    set -l gnome_dir "$XDG_CONFIG_HOME/yadm/gnome"
    mkdir -p "$gnome_dir"
    set -l output_file "$gnome_dir/settings.ini"

    if command -q gnome-extensions
        gnome-extensions list --enabled >"$gnome_dir/extensions.txt" 2>/dev/null; or true
    end

    set -l exclude_paths org/blueman/plugins/recentconns

    set -l dump (dconf dump /)

    for path in $exclude_paths
        set dump (printf '%s\n' $dump | awk -v pat="[$path]" '
            BEGIN {skip=0}
            /^\[.*\]$/ {
                if ($0 == pat) { skip=1; next }
                else { skip=0 }
            }
            !skip { print }
        ')
    end

    printf '%s\n' $dump >"$output_file"
end
