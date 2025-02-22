# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# shopt utils
shopt -s histappend
shopt -s checkwinsize
shopt -s globstar

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# colors in gcc
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# alias definitions.
if [ -f "$HOME/.bash_aliases" ]; then
    source "$HOME/.bash_aliases"
fi

# bash functions
if [ -f "$HOME/.bash_functions.sh" ]; then
    source "$HOME/.bash_functions.sh"
fi

# bash binds
if [ -f "$HOME/.bash_binds.sh" ]; then
    source "$HOME/.bash_binds.sh"
fi

# my fzf
if [ -f "$HOME/.my_fzf.sh" ]; then
    source "$HOME/.my_fzf.sh"
fi

# bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
# if [ -f /etc/bash_completion ]; then
# 	. /etc/bash_completion
# fi

MY_PROJECT_PATH="$(pwd)"
export MY_PROJECT_PATH

# editor
export EDITOR='nvim'

# linuxbrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# oh my posh
eval "$(oh-my-posh init bash --config "$HOME"/.config/ohmyposh/my_amro.toml)"
# eval "$(oh-my-posh init bash --config "$(brew --prefix oh-my-posh)"/themes/amro.omp.json)"

# my apps paths
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export IGNOREEOF=999

export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:~/go/bin"

eval "$(zoxide init --cmd cd bash)"

eval "$(fzf --bash)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() {
    fd --type d --hidden --exclude .git . "$1"
}

# source ~/fzf-git.sh/fzf-git.sh

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

eval "$(thefuck --alias fk)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH="$PATH:/home/talinux/.dotnet/tools"
export PATH=$PATH:~/Unity/Hub/Editor/6000.0.23f1/Editor
export PATH=$PATH:~/.cargo/env
export PATH="$PATH:/usr/local/bin/tmux"
export PATH="$PATH:$HOME/.config/yadm/bin/"

export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export HYPRSHOT_DIR="$HOME/Pictures/screenshots/"
export XDG_PICTURES_DIR="$HOME/Pictures"
export TERMINAL="kitty"

eval "$(thefuck --alias)"

export ANDROID_HOME=$HOME/.AndroidS/Sdk/
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
. "$HOME/.cargo/env"
