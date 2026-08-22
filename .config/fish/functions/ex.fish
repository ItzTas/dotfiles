function ex
    argparse -N 1 -X 1 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function)" <archive>" \
            "  extracts tar/gz/bz2/xz/zst/zip/rar/7z/Z/deb archives"
        return 0
    end

    if not path is -f -- "$argv[1]"
        echo "'$argv[1]' is not a valid file."
        return 1
    end

    switch "$argv[1]"
        case '*.tar.bz2'
            tar xjf "$argv[1]"
        case '*.tar.gz'
            tar xzf "$argv[1]"
        case '*.bz2'
            bunzip2 "$argv[1]"
        case '*.rar'
            if command -q rar
                rar x "$argv[1]"
            else if command -q unrar
                unrar x "$argv[1]"
            else
                echo "Please install 'rar' or 'unrar' to extract RAR files."
            end
        case '*.gz'
            gunzip "$argv[1]"
        case '*.tar'
            tar xf "$argv[1]"
        case '*.tbz2'
            tar xjf "$argv[1]"
        case '*.tgz'
            tar xzf "$argv[1]"
        case '*.zip'
            unzip "$argv[1]"
        case '*.Z'
            uncompress "$argv[1]"
        case '*.7z'
            7zr x "$argv[1]"
        case '*.deb'
            ar x "$argv[1]"
        case '*.tar.xz'
            tar xf "$argv[1]"
        case '*.tar.zst'
            unzstd "$argv[1]"
        case '*'
            echo "Cannot extract '$argv[1]' with "(status current-function)"()"
    end
end
