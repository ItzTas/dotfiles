function sesh_connect
    for dep in sesh fzf-tmux
        if not command -q $dep
            echo "$dep is not installed" >&2
            return 1
        end
    end

    set -l selection (
        sesh list --icons | fzf-tmux -p 90%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(chmod +x ~/.config/sesh/scripts/kill_safe.sh && ~/.config/sesh/scripts/kill_safe.sh {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-i:preview-up,ctrl-u:preview-down' \
            --bind 'ctrl-y:accept' \
            --preview-window 'right:50%' \
            --preview 'sesh preview {}'
    )

    test -n "$selection"; and sesh connect "$selection"
end
