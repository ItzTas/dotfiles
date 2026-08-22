complete -c net-rescue -f
complete -c net-rescue -s i -l octet -x -d 'final octet (2-254)'
complete -c net-rescue -s c -l connection -x -d 'NetworkManager connection' -a '(nmcli -g NAME connection show 2>/dev/null)'
complete -c net-rescue -s h -l help -d 'show usage'
