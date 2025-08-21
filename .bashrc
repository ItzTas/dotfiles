# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# shopt
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

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
        "fzf"
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
