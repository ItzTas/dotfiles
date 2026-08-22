function git --wraps git
    if not command -q git
        echo "git is not installed" >&2
        return 1
    end

    set -l args
    set -l has_diff false
    set -l no_pager false

    for arg in $argv
        if test "$arg" = --no-pager
            set no_pager true
        else if test "$arg" = diff
            set has_diff true
        else
            set -a args "$arg"
        end
    end

    if test $has_diff = true -a $no_pager = true; and command -q diff-so-fancy
        command git diff $args | diff-so-fancy
    else
        command git $argv
    end
end
