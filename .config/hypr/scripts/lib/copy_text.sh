# shellcheck shell=bash
# Copies the text OCR finds in an image to the clipboard.

copy_text() {
	local app="$1"
	local icon="$2"
	local path="$3"

	local text
	text=$(tesseract "$path" - -l por+eng 2>/dev/null | sed -e 's/[[:space:]]*$//' | sed -e '/./,$!d')

	if [[ -z "${text//[[:space:]]/}" ]]; then
		dunstify -a "$app" -I "$icon" -u low "No text found" "OCR found no text in the screenshot"
		return
	fi

	printf '%s' "$text" | wl-copy
	dunstify -a "$app" -I "$icon" "Text copied" "$(printf '%s' "$text" | head -c 200)"
}
