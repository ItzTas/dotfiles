function test_memory
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <size>" \
            "  <size>  amount to allocate, e.g. 2G"
        return 0
    end

    head -c "$argv[1]" </dev/zero | tail
end
