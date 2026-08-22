function ubw
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  unlocks Bitwarden and exports BW_SESSION"
        return 0
    end

    if not command -q bw
        echo "bw is not installed" >&2
        return 1
    end

    set -gx BW_SESSION (bw unlock --raw)
end
