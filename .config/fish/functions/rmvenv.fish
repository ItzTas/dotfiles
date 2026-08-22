function rmvenv
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <name>" \
            "  <name>  virtualenv under \$VENV_HOME"
        return 0
    end

    set -l venv "$VENV_HOME/$argv[1]"

    if not path is -d -- "$venv"
        echo "no virtualenv named '$argv[1]' in $VENV_HOME" >&2
        return 1
    end

    rm -r "$venv"
end
