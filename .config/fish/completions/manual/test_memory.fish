complete -c test_memory -f
complete -c test_memory -n __fish_is_first_arg -a '512M 1G 2G 4G 8G' -d size
complete -c test_memory -s h -l help -d 'show usage'
