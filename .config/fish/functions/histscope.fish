function histscope --description "Switch which history file this session reads and writes"
    argparse h/help p/project t/tmux r/reset l/list -- $argv
    or return

    set -l store "$XDG_DATA_HOME/fish"
    test -n "$XDG_DATA_HOME"; or set store "$HOME/.local/share/fish"

    if set -q _flag_help
        printf '%s\n' \
            "usage: histscope [NAME]" \
            "       histscope --project | --tmux | --reset | --list" >&2
        return 0
    end

    if set -q _flag_list
        set -l active (__histscope_current)

        for file in $store/*_history
            set -l name (path basename -- $file | string replace -r '_history$' '')
            set -l mark " "
            test "$name" = "$active"; and set mark "*"
            printf '%s %s  %s entries\n' $mark (string pad -w 24 -r -- $name) (string pad -w 6 -- (command grep -c '^- cmd:' $file))
        end
        return 0
    end

    if set -q _flag_reset
        set -e fish_history
        echo (__histscope_current)
        return 0
    end

    set -l name $argv[1]

    if set -q _flag_project
        set -l root (git rev-parse --show-toplevel 2>/dev/null)
        test -n "$root"; or set root "$PWD"
        set name (path basename -- $root)
    end

    if set -q _flag_tmux
        if not set -q TMUX
            echo "not inside a tmux session" >&2
            return 1
        end
        set name (tmux display-message -p '#S' 2>/dev/null)
    end

    if test -z "$name"
        echo (__histscope_current)
        return 0
    end

    set name (string replace -ra '[^A-Za-z0-9._-]' _ -- $name)

    if test -z "$name"
        echo "empty history name" >&2
        return 1
    end

    set -g fish_history $name
    echo $name
end

function __histscope_current
    set -q fish_history; and test -n "$fish_history"; and echo $fish_history; and return
    echo fish
end
