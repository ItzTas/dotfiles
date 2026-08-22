function tmux_manager
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
