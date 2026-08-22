complete -c setgtkicons -f
complete -c setgtkicons -n __fish_is_first_arg -a '(path basename (path sort -u --key=basename (path filter -d -- ~/.icons/* ~/.local/share/icons/* /usr/share/icons/*)))' -d 'icon theme'
complete -c setgtkicons -s h -l help -d 'show usage'
