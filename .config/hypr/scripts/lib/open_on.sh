# shellcheck shell=bash
# @use open_path copy_text

open_on() {
	local app="$1"
	local icon="$2"
	local title="$3"
	local body="$4"
	local path="$5"
	local ocr="$6"

	local actions=(
		--action="copy_path,copy path"
		--action="default,open"
		--action="copy,copy"
	)
	[[ "$ocr" == "ocr" ]] && actions+=(--action="copy_text,copy text")

	local action
	action=$(dunstify -a "$app" -I "$icon" "${actions[@]}" "$title" "$body")

	case "$action" in
	"default" | "open")
		open_path "$path"
		;;
	"copy_path")
		wl-copy "$path"
		;;
	"copy")
		local mime
		mime=$(file -b --mime-type "$path")
		wl-copy --type "$mime" <"$path"
		;;
	"copy_text")
		copy_text "$app" "$icon" "$path"
		;;
	esac
}
