complete -c setgtkicons -f -a '(find ~/.icons ~/.local/share/icons /usr/share/icons -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sort -u)' -d 'icon theme'
