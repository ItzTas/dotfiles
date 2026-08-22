function net-auto
    argparse -X 0 'c/connection=' h/help -- $argv
    or begin
        echo "❌ Invalid flag. Use -h for help."
        return 1
    end

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" [-c connection]" \
            "  -c  connection name (default: Wired connection 1)"
        return 0
    end

    if not command -q nmcli
        echo "nmcli is not installed" >&2
        return 1
    end

    set -l connection "Wired connection 1"
    set -q _flag_connection; and set connection "$_flag_connection"

    sudo nmcli connection modify "$connection" ipv4.method auto
    and sudo nmcli connection up "$connection"
    and echo "✅ Automatic DHCP restored on \"$connection\""
end
