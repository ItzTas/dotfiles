function __omniroute_spawn
    set -l tmp /tmp
    test -n "$TMPDIR"; and set tmp "$TMPDIR"
    set -g __omniroute_log "$tmp/omniroute-start.$fish_pid.log"

    command $argv >"$__omniroute_log" 2>&1
    set -l ret $status

    test $ret -eq 0; and return 0

    echo "❌ omniroute failed to start (exit $ret)" >&2
    __omniroute_dump_log

    return $ret
end
