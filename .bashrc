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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

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

# bash evals
if [ -f "$HOME/.bash_evals.sh" ]; then
    source "$HOME/.bash_evals.sh"
fi

# my fzf
if [ -f "$HOME/.my_fzf.sh" ]; then
    source "$HOME/.my_fzf.sh"
fi

# bash completions
if [ -f "$HOME/.completions.sh" ]; then
    source "$HOME/.completions.sh"
fi

export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:~/go/bin"

export PATH=$PATH:/var/lib/snapd/snap/bin
export PATH="$PATH:/home/talinux/.dotnet/tools"
export PATH=$PATH:~/Unity/Hub/Editor/6000.0.23f1/Editor
export PATH=$PATH:~/.cargo/env

export ANDROID_HOME=$HOME/.AndroidS/Sdk/
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH

# yay completions
# if [ -f /usr/share/bash-completion/completions/yay ]; then
#     source /usr/share/bash-completion/completions/yay
# fi
. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/talinux/.lmstudio/bin"
# End of LM Studio CLI section
