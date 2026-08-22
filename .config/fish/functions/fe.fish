function fe
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  picks a git branch with fzf; ctrl-y switches to it"
        return 0
    end

    for dep in git fzf
        if not command -q $dep
            echo "$dep is not installed" >&2
            return 1
        end
    end

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Error: not in a git directory"
        return 1
    end

    set -l b (git branch -a | grep -v '\->' | sed 's|remotes/origin/||' | sed 's|^\* ||' | sed 's/^ *//;s/ *$//' | sort -u)

    printf '%s\n' $b | fzf --bind 'ctrl-y:execute(git switch {})+abort'
end
