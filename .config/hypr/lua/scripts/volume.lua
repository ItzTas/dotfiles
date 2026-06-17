local utils = require("functions.utils")
local notify = require("envs.notify")

local ICON_DIR = notify.ICON_DIR
local REPLACE_ID = notify.REPLACE_ID

local M = {}

---@param step integer e.g. 5 for +5%, -5 for -5%
function M.adjust(step)
	local sign = step >= 0 and "+" or "-"
	local abs = math.abs(step)
	local limit = step >= 0 and "-l 1 " or ""

	utils.run_async_cmd(
		string.format(
			"wpctl set-volume %s@DEFAULT_AUDIO_SINK@ %d%%%s;"
				.. " vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}');",
			limit,
			abs,
			sign,
			ICON_DIR,
			REPLACE_ID
		)
	)
end

function M.toggle_mute()
	utils.run_async_cmd(
		string.format(
			"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle;"
				.. " muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}');"
				.. ' if [ "$muted" = "[MUTED]" ]; then'
				.. '   icon="volume-mute.svg"; msg="Audio: Muted";'
				.. " else"
				.. '   icon="volume.svg"; msg="Audio: Unmuted";'
				.. " fi;"
				.. ' notify-send "$msg" -e --icon="%s/$icon" --expire-time=500 --replace-id=%d',
			ICON_DIR,
			REPLACE_ID
		)
	)
end

return M
