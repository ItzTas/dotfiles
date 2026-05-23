local utils = require("functions.utils")
local notify = require("envs.notify")

local ICON_DIR = notify.ICON_DIR
local REPLACE_ID = notify.REPLACE_ID

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
            ICON_DIR, REPLACE_ID
        )
    )
end

return M
