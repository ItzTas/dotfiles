function lse
    argparse -X 1 h/help -- $argv
    or return 1

    set -l usage "Usage: "(status current-function)" <archive>" \
        "  lists the contents of tar/gz/bz2/xz/zst/zip/rar/7z/Z/deb archives"

    if set -q _flag_help
        printf '%s\n' $usage
        return 0
    end

    if test (count $argv) -ne 1
        printf '%s\n' $usage >&2
        return 1
    end

    if not path is -f -- "$argv[1]"
        echo "'$argv[1]' is not a valid file"
        return 1
    end

    switch "$argv[1]"
        case '*.tar.bz2' '*.tbz2'
            tar tjf "$argv[1]"
        case '*.tar.gz' '*.tgz'
            tar tzf "$argv[1]"
        case '*.tar.xz'
            tar tJf "$argv[1]"
        case '*.tar.zst'
            unzstd -c "$argv[1]" | tar tf -
        case '*.tar'
            tar tf "$argv[1]"
        case '*.bz2'
            bunzip2 -l "$argv[1]"
        case '*.gz'
            gzip -l "$argv[1]"
        case '*.zip'
            unzip -l "$argv[1]"
        case '*.rar'
            if command -q rar
                rar l "$argv[1]"
            else if command -q unrar
                unrar l "$argv[1]"
            else
                echo "Install rar or unrar to list .rar files"
            end
        case '*.7z'
            7z l "$argv[1]"
        case '*.Z'
            uncompress -c "$argv[1]" | wc -c
        case '*.deb'
            ar t "$argv[1]"
        case '*'
            echo "'$argv[1]' cannot be listed by "(status current-function)"()"
    end
end
