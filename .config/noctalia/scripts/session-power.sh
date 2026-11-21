#!/usr/bin/env bash
# Graceful reboot/poweroff through hyprshutdown, falling back to plain systemctl
# when hyprshutdown dies before reaching --post-cmd (e.g. it aborts in initEGL
# after an NVIDIA driver upgrade, while the old kernel module is still loaded).
#
# Usage: session-power.sh reboot|poweroff
# Callers should launch it with `setsid -f` so it survives Hyprland exiting.
set -u

declare -A labels=([reboot]='Restarting...' [poweroff]='Shutting down...')
action=${1:-}
label=${labels[$action]:-}
if [[ -z $label ]]; then
	echo "usage: ${0##*/} reboot|poweroff" >&2
	exit 2
fi

# tmux kill-server first: lingering tmux panes otherwise stall shutdown ~90s
post="tmux kill-server; systemctl $action"

hyprshutdown --no-fork -t "$label" --post-cmd "$post" && exit 0

logger -t session-power "hyprshutdown failed (exit $?), running systemctl $action directly"
tmux kill-server
systemctl "$action"
