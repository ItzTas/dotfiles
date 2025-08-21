# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# shopt
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

__source_bash_files() {
    # bash files home
    local bash_home="$HOME/.bash"

    local files=(
        "aliases"
        "functions"
        "binds"
        "exports"
        "evals"
        "sources"
    )

    local file path
    for file in "${files[@]}"; do
        path="$bash_home/$file"
        if [ -f "$path" ]; then
            # shellcheck disable=SC1090
            source "$path"
        fi
    done
}
__source_bash_files
unset __source_bash_files
