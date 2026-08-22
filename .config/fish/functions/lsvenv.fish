function lsvenv
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  lists the virtualenvs under \$VENV_HOME"
        return 0
    end

    path basename (path filter -d -- $VENV_HOME/*)
end
