function dumpproto
    if not command -q proto
        echo "proto is not installed" >&2
        return 1
    end

    if test -e .prototools
        echo ".prototools already exists! Aborting." >&2
        return 1
    end

    printf '%s\n' \
        '[settings]' \
        'auto-install = true' \
        'telemetry = false' \
        'unstable-lockfile = true' \
        'auto-clean = true' >.prototools

    echo ".prototools file created!"
end
