function mggo
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <owner/repo>" \
        "  opens https://github.com/<owner/repo> with miru"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    if not command -q miru
        echo "miru is not installed" >&2
        return 1
    end

    miru go "https://github.com/$argv[1]"
end
