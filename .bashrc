# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

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
        "shopt"
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
