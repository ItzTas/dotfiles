complete -c activatevenv -f
complete -c activatevenv -n __fish_is_first_arg -a '(path basename (path filter -d -- $VENV_HOME/*))' -d virtualenv
complete -c activatevenv -s h -l help -d 'show usage'
