local utils = require("functions.utils")

local DUNST_ICON = os.getenv("HOME") .. "/.config/dunst/assets"
local REPLACE_ID = 2593

local M = {}

function M.toggle_mute()
    utils.run_async_cmd(
        string.format(
            "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle;"
                .. " muted=$(wpctl get-mute @DEFAULT_AUDIO_SOURCE@);"
                .. ' if echo "$muted" | grep -q true; then'
                .. '   icon="mic-mute.svg"; msg="Microphone: Muted";'
                .. " else"
                .. '   icon="mic.svg"; msg="Microphone: Unmuted";'
                .. " fi;"
                .. ' notify-send -e -i "%s/$icon" -r %d "$msg"',
            DUNST_ICON, REPLACE_ID
        )
    )
end

return M
