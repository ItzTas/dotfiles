function net-rescue
    argparse 'i/octet=' 'c/connection=' h/help -- $argv
    or begin
        echo "❌ Invalid flag. Use -h for help."
        return 1
    end

    if set -q _flag_help
        echo "Usage: net-rescue [-i octet] [-c connection]"
        echo "  -i  final octet (default: 20)"
        echo "  -c  connection name (default: Wired connection 1)"
        return 0
    end

    set -l octet 20
    set -q _flag_octet; and set octet "$_flag_octet"

    set -l connection "Wired connection 1"
    set -q _flag_connection; and set connection "$_flag_connection"

    if not string match -qr '^[0-9]+$' -- "$octet"; or test "$octet" -lt 2 -o "$octet" -gt 254
        echo "❌ Invalid octet: '$octet'. Use a number between 2 and 254."
        return 1
    end

    sudo nmcli connection modify "$connection" \
        ipv4.method manual \
        ipv4.addresses "192.168.100.$octet/24" \
        ipv4.gateway 192.168.100.1 \
        ipv4.dns "192.168.100.1"
    and sudo nmcli connection up "$connection"
    and echo "✅ Static IP 192.168.100.$octet active on \"$connection\""
end
