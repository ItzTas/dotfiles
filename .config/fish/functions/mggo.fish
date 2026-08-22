function mggo
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <owner/repo>" \
            "  opens https://github.com/<owner/repo> with miru"
        return 0
    end

    if not command -q miru
        echo "miru is not installed" >&2
        return 1
    end

    miru go "https://github.com/$argv[1]"
end
