# Installed GTK themes, user directory first. `find` rather than a glob so a
# missing directory stays silent instead of erroring out.
complete -c setgtktheme -f -a '(find ~/.themes ~/.local/share/themes /usr/share/themes -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sort -u)' -d theme
