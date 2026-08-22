function sc --wraps 'sesh clone'
    for dep in sesh tmux
        if not command -q $dep
            echo "$dep is not installed" >&2
            return 1
        end
    end

    sesh clone $argv; or return 1

    set -l session_name "Projects 📂"
    if tmux has-session -t "$session_name"
        tmux kill-session -t "$session_name"
    end
end
