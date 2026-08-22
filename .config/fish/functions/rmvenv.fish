function rmvenv
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <name>" \
        "  <name>  virtualenv under \$VENV_HOME"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    set -l venv "$VENV_HOME/$argv[1]"

    if not path is -d -- "$venv"
        echo "no virtualenv named '$argv[1]' in $VENV_HOME" >&2
        return 1
    end

    rm -r "$venv"
end
