function fe
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: not in a git directory"
        return 1
    end

    set -l b (git branch -a | grep -v '\->' | sed 's|remotes/origin/||' | sed 's|^\* ||' | sed 's/^ *//;s/ *$//' | sort -u)

    printf '%s\n' $b | fzf --bind 'ctrl-y:execute(git switch {})+abort'
end
