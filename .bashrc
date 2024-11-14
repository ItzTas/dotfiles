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
    alias ls='lsd'
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
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

MY_PROJECT_PATH="$(pwd)"
export MY_PROJECT_PATH

# my aliases
alias ksee='kitty +kitten icat'
alias y='yazi'
alias screenK='screenkey -p fixed --geometry 500x70+1200+120 -f "JetBrains Mono" -s small '
alias python='python3'
alias gitGraph='git --no-pager log --oneline --graph --all --decorate --stat --color --pretty=format:"%h %d %s %an %ar"'
alias ls='lsd'
alias grep='grep --color=always'
alias vim='nvim'
alias c='bat --paging=never'
alias renderMarkdown='grip'
alias tattach='tmux attach'
alias v='nvim .'
alias tds='tmux new-session -s default'

export EDITOR='nvim'

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# oh my posh
eval "$(oh-my-posh init bash --config "$HOME"/.config/ohmyposh/my_amro.toml)"
# eval "$(oh-my-posh init bash --config "$(brew --prefix oh-my-posh)"/themes/amro.omp.json)"

# manage_tmux_session() {
#     # Check if tmux is installed and not already inside a tmux session
#     if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
#         if tmux has-session -t nop 2>/dev/null; then
#             echo "nop session"
#             return 0
#         fi
#
#         if [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 0 ]; then
#             tmux attach
#         else
#             tmux has-session -t default 2>/dev/null
#             if [ $? != 0 ]; then
#                 tmux new-session -s default
#             else
#                 tmux attach-session -t default
#             fi
#         fi
#     fi
# }

###------------------- PROMPT -----------------------###

function parse_git_dirty {
    STATUS="$(git status 2>/dev/null)"
    if [[ $? -ne 0 ]]; then
        printf ""
        return
    else printf " ["; fi
    if echo "${STATUS}" | grep -c "renamed:" &>/dev/null; then printf " >"; else printf ""; fi
    if echo "${STATUS}" | grep -c "branch is ahead:" &>/dev/null; then printf " !"; else printf ""; fi
    if echo "${STATUS}" | grep -c "new file::" &>/dev/null; then printf " +"; else printf ""; fi
    if echo "${STATUS}" | grep -c "Untracked files:" &>/dev/null; then printf " ?"; else printf ""; fi
    if echo "${STATUS}" | grep -c "modified:" &>/dev/null; then printf " *"; else printf ""; fi
    if echo "${STATUS}" | grep -c "deleted:" &>/dev/null; then printf " -"; else printf ""; fi
    printf " ]"
}

parse_git_branch() {
    # Long form
    git rev-parse --abbrev-ref HEAD 2>/dev/null
    # Short form
    # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}

prompt_comment() {
    DIR="$HOME/.local/share/promptcomments/"
    MESSAGE="$(find "$DIR"/*.txt | shuf -n1)"
    cat "$MESSAGE"
}

#PS1="\e[00;36m\]┌─[ \e[00;37m\]\T \d \e[00;36m\]]──\e[00;31m\]>\e[00;37m\] \u\e[00;31m\]@\e[00;37m\]\h\n\e[00;36m\]|\n\e[00;36m\]└────\e[00;31m\]> \e[00;37m\]\w \e[00;31m\]\$ \e[01;37m\]"
#PS1="\[\e[01;37m\]{ \[\e[01;34m\]\w \[\e[01;37m\]} \[\e[01;35m\]\[\$ \]\[\e[01;37m\]"
#PS1="\[\e[1;36m\]\$(parse_git_branch)\[\033[31m\]\$(parse_git_dirty)\[\033[00m\]\n\w\[\e[1;31m\] \[\e[1;36m\]\[\e[1;37m\] "
#PS1="\[\e[1;33m\]\$(parse_git_branch)\[\033[34m\]\$(parse_git_dirty)\n\[\033[1;36m\]  \[\e[1;37m\] \w \[\e[1;37m\]\[\e[0;37m\] "
# PS1="\[\e[1;33m\]\$(parse_git_branch)\[\033[34m\]\$(parse_git_dirty)\n\[\033[1;34m\] 󰣇 \[\e[1;37m\] \w \[\e[1;36m\]\[\e[0;37m\] "

###---------- ARCHIVE EXTRACT ----------###

ex() {
    if [ -f $1 ]; then
        case $1 in
        *.tar.bz2) tar xjf $1 ;;
        *.tar.gz) tar xzf $1 ;;
        *.bz2) bunzip2 $1 ;;
        *.rar) unrar x $1 ;;
        *.gz) gunzip $1 ;;
        *.tar) tar xf $1 ;;
        *.tbz2) tar xjf $1 ;;
        *.tgz) tar xzf $1 ;;
        *.zip) unzip $1 ;;
        *.Z) uncompress $1 ;;
        *.7z) 7za e x $1 ;;
        *.deb) ar x $1 ;;
        *.tar.xz) tar xf $1 ;;
        *.tar.zst) unzstd $1 ;;
        *) echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

fs() {
    local session
    session=$(tmux list-sessions -F "#{session_name}" | fzf)
    tmux switch-client -t "$session"
}

p() {
    cd "$MY_PROJECT_PATH" || return
}

fe() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Erro: não está dentro de um repositório Git."
        return 1
    fi

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
    dir=$( (
        zoxide query -l
        find . -type d
    ) | fzf --preview 'eza --icons --tree --level 3 -F {}') && cd "$dir" || return
}

fv() {
    f
    nvim .
}

fvv() {
    local file
    file="$(find . -type f | fzf --preview 'bat --style=numbers --color=always {}')"
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

    find "$project_path" -type f -exec sed -i "s/$old_name/$new_name/g" {} +
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

# new_ss() {
# 	local last_dir
# 	last_dir="$(pwd)"
#
# 	local direc
# 	direc=$(find "$HOME" -type d | fzf --preview 'lsd --tree --depth=2 -1F {}')
#
# 	direc="${direc##*( )}"
# 	direc="${direc%%*( )}"
# 	if [[ -z "$direc" ]]; then
# 		return 0
# 	fi
#
# 	builtin cd "$direc" || return
#
# 	local d
# 	d="$(basename "$(pwd)")"
#
# 	d="${d//./_}"
#
# 	if [[ d == "$USER" ]]; then
# 		return 0
# 	fi
#
# 	tmux new-session -d -s "$d"
# 	while ! tmux has-session -t "$d"; do
# 		sleep 0.01
# 	done
#
# 	cd "$last_dir" || return
#
# 	tmux switch-client -t "$d"
#
# }

pf() {
    p
    f
}

sesh_connect() {
    local selection
    selection=$(
        sesh list --icons | fzf \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)'
    )
    [[ -n "$selection" ]] && sesh connect "$selection"
}

# my binds
# bind -x '"\eb":"pf"'
bind -x '"\eg":"lsd -F"'
bind -x '"\ey":"yazi"'
# bind -x '"\C-f":new_ss'
bind -x '"\C-b":f'
# bind -x '"\C-a":fs'
bind -x '"\C-o":fe'

tmux_manager() {
    if [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 0 ]; then
        tmux attach
    else

        if ! tmux has-session -t default 2>/dev/null; then
            tmux new-session -s default
        else
            tmux attach-session -t default
        fi
    fi
    bind -r "\C-g"
}

if [ -z "$TMUX" ]; then
    bind -x '"\C-f":sesh_connect'
    bind -x '"\C-g":tmux_manager'
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
export PATH="$HOME/.bun/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

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
. "$HOME/.cargo/env"
export PATH=$PATH:~/.cargo/env
export PATH="$PATH:/usr/local/bin/tmux"
export PATH="$PATH:$HOME/.config/yadm/bin/"

export HYPRCURSOR_THEME="Bibata-Modern-Classic"
export HYPRSHOT_DIR="$HOME/Pictures/screenshots/"
export XDG_PICTURES_DIR="$HOME/Pictures"
export TERMINAL="kitty"

eval "$(thefuck --alias)"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Load Angular CLI autocompletion.
source <(ng completion script)
