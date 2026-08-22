function dirh_widget --description "Pick a directory from this session's directory history"
    if not command -q fzf
        dirh
        commandline -f repaint
        return
    end

    set -l dirs $dirprev $PWD $dirnext

    if test (count $dirs) -le 1
        commandline -f repaint
        return
    end

    set -l here (math (count $dirprev) + 1)
    set -l rows

    for i in (seq (count $dirs))
        set -l offset (math $i - $here)
        set -l mark (string pad -w 4 -- $offset)

        test $offset -eq 0; and set mark (string pad -w 4 -- ·)

        set -l display (string replace -r -- "^$HOME" '~' $dirs[$i] | string shorten -m 70 --left)
        set -a rows "$offset"\t"$dirs[$i]"\t"$mark  $display"
    end

    set -l preview 'lsd --icon always --tree --depth 2 -F {2}'
    command -q lsd; or set preview 'ls -F {2}'

    set -l pick (printf '%s\n' $rows | fzf --tac --delimiter=\t --with-nth=3 --preview=$preview)

    set -l offset (string split -f1 \t -- "$pick")

    if test -z "$offset"
        commandline -f repaint
        return
    end

    test $offset -lt 0; and prevd (math 0 - $offset)
    test $offset -gt 0; and nextd $offset

    commandline -f repaint
end
