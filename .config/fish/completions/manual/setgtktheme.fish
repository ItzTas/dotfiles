complete -c setgtktheme -f
complete -c setgtktheme -n __fish_is_first_arg -a '(path basename (path sort -u --key=basename (path filter -d -- ~/.themes/* ~/.local/share/themes/* /usr/share/themes/*)))' -d theme
complete -c setgtktheme -s h -l help -d 'show usage'
