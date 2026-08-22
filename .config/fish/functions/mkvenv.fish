function mkvenv
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <name>" \
        "  <name>  virtualenv to create under \$VENV_HOME"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    if not command -q python3
        echo "python3 is not installed" >&2
        return 1
    end

    if path is -d -- "$VENV_HOME/$argv[1]"
        echo "virtualenv '$argv[1]' already exists" >&2
        return 1
    end

    python3 -m venv "$VENV_HOME/$argv[1]"
end
