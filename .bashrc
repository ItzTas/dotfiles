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

# bash exports
if [ -f "$HOME/.bash_exports.sh" ]; then
    source "$HOME/.bash_exports.sh"
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

# linuxbrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# oh my posh
eval "$(oh-my-posh init bash --config "$HOME"/.config/ohmyposh/my_amro.toml)"
# eval "$(oh-my-posh init bash --config "$(brew --prefix oh-my-posh)"/themes/amro.omp.json)"

eval "$(zoxide init --cmd cd bash)"

eval "$(thefuck --alias fk)"

# my apps paths
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:~/go/bin"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH="$PATH:/home/talinux/.dotnet/tools"
export PATH=$PATH:~/Unity/Hub/Editor/6000.0.23f1/Editor
export PATH=$PATH:~/.cargo/env
export PATH="$PATH:/usr/local/bin/tmux"
export PATH="$PATH:$HOME/.config/yadm/bin/"

eval "$(thefuck --alias)"

export ANDROID_HOME=$HOME/.AndroidS/Sdk/
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
. "$HOME/.cargo/env"
