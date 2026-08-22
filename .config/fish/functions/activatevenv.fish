function activatevenv
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <name>" \
            "  <name>  virtualenv under \$VENV_HOME"
        return 0
    end

    set -l activate "$VENV_HOME/$argv[1]/bin/activate.fish"

    if not path is -f -- "$activate"
        echo "no virtualenv named '$argv[1]' in $VENV_HOME" >&2
        return 1
    end

    source "$activate"
end
