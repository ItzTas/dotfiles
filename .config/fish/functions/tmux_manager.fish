function tmux_manager
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  attaches to tmux, or starts the 'default' session when none exists"
        return 0
    end

    if not command -q tmux
        echo "tmux is not installed" >&2
        return 1
    end

    set -l session_count (tmux list-sessions 2>/dev/null | wc -l | string trim)

    if test "$session_count" -gt 0
        tmux attach
    else
        tmux new-session -s default
    end
end
