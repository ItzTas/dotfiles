function test_memory
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <size>" \
        "  <size>  amount to allocate, e.g. 2G"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    head -c "$argv[1]" </dev/zero | tail
end
