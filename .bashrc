# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='lsd -alF'
alias la='lsd -A'
alias l='lsd -F'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# my aliases
alias ksee='kitty +kitten icat'
alias bat='batcat'
alias screenK='screenkey -p fixed --geometry 500x70+1200+120 -f "JetBrains Mono" -s small '
alias python='python3'
alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
alias ls='lsd'
alias grep='grep --color=always'
alias vim='nvim'
alias c='batcat --paging=never'
alias renderMarkdown='grip'
alias tattach='tmux attach'
alias v='nvim .'

export EDITOR='nvim'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# oh my posh
eval "$(oh-my-posh init bash --config "$(brew --prefix oh-my-posh)"/themes/amro.omp.json)"

manage_tmux_session() {
    # Check if tmux is installed and not already inside a tmux session
    if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
        if tmux has-session -t nop 2>/dev/null; then
            echo "nop session"
            return 0
        fi

        if [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 0 ]; then
            tmux attach
        else
            tmux has-session -t default 2>/dev/null
            if [ $? != 0 ]; then
                tmux new-session -s default
            else
                tmux attach-session -t default
            fi
        fi
    fi
}

manage_tmux_session

unset -f manage_tmux_session

function fs() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | fzf)
    tmux switch-client -t "$session"
}

fe() {
    local b
    b="$(git branch -a | grep -v '\->' | sed 's|remotes/origin/||' | sed 's|^\* ||' | sed 's/^ *//;s/ *$//' | sort -u)"

    local toB
    toB="$(echo "$b" | fzf)"
    toB="${toB##*( )}"
    toB="${toB%%*( )}"
    if [[ -z "$toB" ]]; then
        return 0
    fi
    git switch "$toB"
}

f() {
    local dir
    dir=$(fd . --type d | fzf --preview 'lsd --tree --depth=2 -1F {}') && builtin cd "$dir"
}

fv() {
    f
    nvim .
}

fvv() {
    local file
    file="$(fd . --type f | fzf --preview 'batcat --style=numbers --color=always {}')"
    file="${file##*( )}"
    file="${file%%*( )}"
    if [[ -z "$file" ]]; then
        return 0
    fi

    nvim "$file"
}

fr() {
    cd "$HOME" && f
}

frv() {
    cd "$HOME" && fv
}

replace_in_files() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: replace_in_files <old_name> <new_name>"
        return 1
    fi

    old_name=$1
    new_name=$2
    project_path=$(pwd)

    if [ -z "$old_name" ]; then
        echo "Old name cannot be empty."
        return 1
    fi

    if [ -z "$new_name" ]; then
        echo "New name cannot be empty."
        return 1
    fi

    fd "$project_path" --type f -exec sed -i "s/$old_name/$new_name/g" {} +
}

ft() {
    local s
    printf "(new-session) "
    read -r s

    tmux new-session -d -s "$s"
    while ! tmux has-session -t "$s" 2>/dev/null; do
        sleep 0.2
    done
    tmux send-keys -t "$s" 'cd && f && clear' C-m
    tmux switch-client -t "$s"
    clear
}

new_ss() {
    f
    local dir
    dir="$(basename "$(pwd)")"

    tmux new-session -d -s "$dir"
    while ! tmux has-session -t "$dir"; do
        sleep 0.01
    done
    tmux switch-client -t "$dir"
}

# my binds
bind -x '"\C-f":new_ss'
bind -x '"\C-a":f'
# bind -x '"\C-a":fs'
bind -x '"\C-e":fe'

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
export PATH="$HOME/.bun/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

export IGNOREEOF=999

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

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

source ~/fzf-git.sh/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'batcat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'lsd --tree --depth=2 -1F {}'"

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview 'lsd --tree --depth=2 -1F {}' ;;
    export | unset) fzf --preview "eval 'echo \$' {}" "$@" ;;
    ssh) fzf --preview 'dig {}' "$@" ;;
    *) fzf --preview "--preview 'bat -n --color=aways --line-range :500 {}'" "$@" ;;
    esac
}

eval "$(thefuck --alias fk)"
