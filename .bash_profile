#
# ~/.bash_profile
#

[[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/talinux/.lmstudio/bin"
# End of LM Studio CLI section

. "$HOME/.cargo/env"
