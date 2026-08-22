complete -c net-auto -f
complete -c net-auto -s c -l connection -x -d 'NetworkManager connection' -a '(nmcli -g NAME connection show 2>/dev/null)'
complete -c net-auto -s h -l help -d 'show usage'
