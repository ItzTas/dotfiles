eval "$(fzf --bash)"

# source ~/fzf-git.sh/fzf-git.sh

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --exclude .git . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --icons --tree --level 2 -F {}'"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview 'eza --icons --tree --level 2 -F {}' ;;
    export | unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview 'bat -n --color=aways --line-range :500 {}' "$@" ;;
    esac
}
