function omniroute --wraps omniroute
    if not command -q omniroute
        echo "omniroute is not installed" >&2
        return 1
    end

    if test (count $argv) -eq 0
        command omniroute serve --no-open
        return
    end

    if test "$argv[1]" != serve
        command omniroute $argv
        return
    end

    command omniroute serve --no-open $argv[2..]
end
