function sc
    sesh clone $argv; or return 1

    set -l session_name "Projects 📂"
    if tmux has-session -t "$session_name"
        tmux kill-session -t "$session_name"
    end
end
