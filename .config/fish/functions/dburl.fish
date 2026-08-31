function dburl --description 'Break a database URL into its individual fields'
    argparse -X 1 h/help p/private m/mask -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" [-p] [-m] [URL|-]" \
            "" \
            "Prints every field of a database URL: driver, user, password," \
            "host, port, database and each query parameter." \
            "" \
            "  URL              the URL to parse; '-' reads it from stdin" \
            "  -p, --private    read the URL from a hidden prompt (never echoed," \
            "                   never stored in the shell history)" \
            "  -m, --mask       print the password as ******" \
            "  -h, --help       show this help" \
            "" \
            "With no argument, \$DATABASE_URL is used, or the hidden prompt if it is unset."
        return 0
    end

    set -l url

    if set -q _flag_private
        read -s -P 'Database URL: ' url
        or return 1
        echo # the hidden prompt leaves the cursor on the same line
    else if test "$argv[1]" = -
        read -z url
        set url (string trim -- "$url")
    else if set -q argv[1]
        set url $argv[1]
    else if set -q DATABASE_URL[1]
        set url $DATABASE_URL
    else
        read -s -P 'Database URL: ' url
        or return 1
        echo
    end

    if test -z "$url"
        echo "no URL given" >&2
        return 1
    end

    # jdbc:postgresql://... carries the real URL after the jdbc: prefix
    set -l rest (string replace -r '^jdbc:' '' -- $url)

    if not string match -rq '^(?<scheme>[a-zA-Z][a-zA-Z0-9+.-]*)://(?:(?<userinfo>[^/?#@]*)@)?(?<hostport>[^/?#]*)(?:/(?<dbname>[^?#]*))?(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?$' -- $rest
        echo "not a database URL: $url" >&2
        return 1
    end

    set -l credentials (string split -m 1 : -- "$userinfo")
    set -l user (string unescape --style=url -- "$credentials[1]")
    set -l password (string unescape --style=url -- "$credentials[2]")

    set -l host "$hostport"
    set -l port ''
    if string match -q '[*' -- "$hostport"
        # IPv6 literal: [::1]:5432
        string match -rq '^\[(?<host>[^\]]*)\](?::(?<port>.*))?$' -- "$hostport"
    else if string match -q '*:*' -- "$hostport"
        set -l address (string split -m 1 : -- "$hostport")
        set host "$address[1]"
        set port "$address[2]"
    end

    if set -q _flag_mask; and test -n "$password"
        set password '******'
    end

    set host (string unescape --style=url -- "$host")
    set -l database (string unescape --style=url -- "$dbname")

    set -l labels Driver User Password Host Port Database
    set -l values "$scheme" "$user" "$password" "$host" "$port" "$database"

    for i in (seq (count $labels))
        test -n "$values[$i]"
        or continue
        printf '%-10s %s\n' "$labels[$i]:" "$values[$i]"
    end

    for param in (string split -n '&' -- "$query")
        set -l pair (string split -m 1 = -- "$param")
        set -l key (string unescape --style=url -- "$pair[1]")
        set -l value (string unescape --style=url -- "$pair[2]")
        printf '%-10s %s\n' "$key:" "$value"
    end

    if test -n "$fragment"
        set -l anchor (string unescape --style=url -- "$fragment")
        printf '%-10s %s\n' Fragment: "$anchor"
    end
end
