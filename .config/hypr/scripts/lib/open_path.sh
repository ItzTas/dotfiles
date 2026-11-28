# shellcheck shell=bash
# Opens a path in $FILE_MANAGER on the focused workspace.

open_path() {
	local path="$1"
	local id

	id=$(hyprctl activeworkspace -j | jq -r '.id')

	if [[ -n "$id" && "$id" != "null" ]]; then
		hyprctl eval "hl.exec_cmd('$FILE_MANAGER \"$path\"', { workspace = '$id' })"
		return
	fi
	"$FILE_MANAGER" "$path"
}
