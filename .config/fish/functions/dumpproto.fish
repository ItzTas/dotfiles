function dumpproto
    argparse -X 0 h/help f/force -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" [-f]" \
            "  -f, --force  overwrite an existing .prototools"
        return 0
    end

    if not command -q proto
        echo "proto is not installed" >&2
        return 1
    end

    if path is .prototools; and not set -q _flag_force
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
