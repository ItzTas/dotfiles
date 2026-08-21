function fsc
    set -l repo (gh repo list --limit 200 --json name,url \
        | jq -r '.[] | "\(.name)\t\(.url)"' \
        | fzf --delimiter='\t' --with-nth=1 \
        | awk -F '\t' '{print $2}')

    test -n "$repo"; and sesh clone "$repo"

    set -l projects_session "Projects 📂"
    if tmux has-session -t "$projects_session"
        tmux kill-session -t "$projects_session"
    end
end
