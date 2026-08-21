function __omniroute_dump_log
    test -s "$__omniroute_log"; or return 0

    cat "$__omniroute_log" >&2
    rm -f "$__omniroute_log"
end
