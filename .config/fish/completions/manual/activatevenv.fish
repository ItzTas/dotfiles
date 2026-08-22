# Virtualenvs living under $VENV_HOME, by name.
complete -c activatevenv -f -a '(ls -1 "$VENV_HOME" 2>/dev/null)' -d virtualenv
