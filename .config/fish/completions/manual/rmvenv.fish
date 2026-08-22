complete -c rmvenv -f
complete -c rmvenv -n __fish_is_first_arg -a '(path basename (path filter -d -- $VENV_HOME/*))' -d virtualenv
complete -c rmvenv -s h -l help -d 'show usage'
