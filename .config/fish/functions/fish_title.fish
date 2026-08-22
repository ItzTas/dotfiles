function fish_title
    set -l cmd $argv[1]
    set -q cmd[1]; or set cmd (status current-command)
    test "$cmd" = fish; and set -e cmd

    set -l dir (path basename -- $PWD)
    test "$PWD" = "$HOME"; and set dir '~'
    test -z "$dir"; and set dir /

    set -l parts
    set -q SSH_TTY; and set -a parts (prompt_hostname | string sub -l 12)":"
    set -q cmd[1]; and set -a parts (string shorten -m 24 -- "$cmd")
    set -a parts $dir

    string join ' ' -- $parts
end
