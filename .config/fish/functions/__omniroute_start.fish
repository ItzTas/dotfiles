function __omniroute_start
    set -l cli "$HOME/.local/bin/omniroute"

    if ss -tln 2>/dev/null | grep -q ':20128'
        return 0
    end

    if test -x "$cli"
        __omniroute_spawn "$cli" serve --daemon --no-open
        return $status
    end

    if command -q omniroute
        __omniroute_spawn omniroute serve --daemon --no-open --no-tray
        return $status
    end

    echo "❌ omniroute not found in ~/.local/bin or \$PATH" >&2
    return 1
end
