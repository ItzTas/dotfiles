#!/usr/bin/env bash
# Brings a tmux pane to the front on Hyprland: focuses the terminal window of a client attached
# to the tmux server (one already on the pane's session, else the most recently active one) and
# switches that client to the pane. With no client attached, opens kitty attached to the session.
# Usage: focus-tmux-pane.sh <pane-id, e.g. %12>

# The tmux server may outlive the Hyprland instance it inherited the env from.
ensure_hyprland_env() {
	hyprctl version >/dev/null 2>&1 && return
	HYPRLAND_INSTANCE_SIGNATURE=$(find "$XDG_RUNTIME_DIR/hypr" -mindepth 1 -maxdepth 1 -printf '%T@ %f\n' |
		sort -rn | awk 'NR == 1 { print $2 }')
	export HYPRLAND_INSTANCE_SIGNATURE
}

# Prints "<pid> <name>" of the best client for the session: on it first, then by recent activity.
pick_client() {
	tmux list-clients -F '#{session_name} #{client_activity} #{client_pid} #{client_name}' |
		awk -v s="$1" '{ print ($1 == s), $2, $3, $4 }' |
		sort -k1,1nr -k2,2nr | awk 'NR == 1 { print $3, $4 }'
}

# Walks up from a process to the ancestor that owns a Hyprland window (the terminal).
window_pid_of() {
	local pid=$1 window_pids
	window_pids=$(hyprctl clients -j | jq -r '.[].pid')
	while ((pid > 1)) && ! grep -qx "$pid" <<<"$window_pids"; do
		pid=$(ps -o ppid= -p "$pid" | tr -d ' ')
	done
	((pid > 1)) && echo "$pid"
}

main() {
	local pane=$1 session client_pid client_name window_pid
	session=$(tmux display -p -t "$pane" '#{session_name}' 2>/dev/null) || exit 1
	ensure_hyprland_env
	tmux select-window -t "$pane" \; select-pane -t "$pane"

	read -r client_pid client_name < <(pick_client "$session")
	if [[ -z $client_pid ]]; then
		setsid -f kitty tmux attach -t "$session" >/dev/null 2>&1
		return
	fi

	window_pid=$(window_pid_of "$client_pid")
	[[ -n $window_pid ]] && hyprctl dispatch focuswindow "pid:$window_pid" >/dev/null
	tmux switch-client -c "$client_name" -t "$session"
}

main "$@"
