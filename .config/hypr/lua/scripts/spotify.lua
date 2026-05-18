local utils = require("functions.utils")

local DUNST_ICON = os.getenv("HOME") .. "/.config/dunst/assets"
local REPLACE_ID = 2593

local M = {}

function M.next()
    utils.run_async_cmd("playerctl -p spotify next")
end

function M.prev()
    utils.run_async_cmd("playerctl -p spotify previous")
end

function M.open_play()
    utils.run_async_cmd(
        'hyprctl dispatch exec "[workspace 9] spotify" || spotify;' .. " sleep 0.8;" .. " playerctl -p spotify play"
    )
end

function M.open_play_silent()
    hl.exec_cmd("spotify", {
        workspace = 9,
        silent = true,
    })

    hl.timer(function()
        utils.run_async_cmd(
            "count=0; "
            .. 'until playerctl -l 2>/dev/null | grep -q spotify || [ "$count" -ge 20 ]; do '
            .. "sleep 0.5; count=$((count+1)); done; "
            .. "sleep 2; "
            .. "playerctl -p spotify volume 0 2>/dev/null; "
            .. "playerctl -p spotify play 2>/dev/null"
        )
    end, { timeout = 1000, type = "oneshot" })
end

---@param delta number
local function adjust_volume(delta)
    local sign = delta >= 0 and "+" or "-"
    local abs_val = string.format("%.2f", math.abs(delta))

    utils.run_async_cmd(
        string.format(
            "status=$(playerctl -p spotify status 2>&1);"
            .. ' if echo "$status" | grep -q "No players found" || [ -z "$status" ]; then exit 0; fi;'
            .. " current=$(playerctl -p spotify volume);"
            .. " new=$(awk -v v=\"$current\" 'BEGIN { v=v%s%s; if(v>1) v=1; if(v<0) v=0; print v }');"
            .. ' playerctl -p spotify volume "$new";'
            .. " vol=$(awk -v v=\"$new\" 'BEGIN { print int(v*100 + 0.5) }');"
            .. ' notify-send -e -h "int:value:$vol" -i "%s/volume.svg" -t 500 -r %d "Spotify: $vol%%"',
            sign,
            abs_val,
            DUNST_ICON,
            REPLACE_ID
        )
    )
end

function M.volume_up()
    adjust_volume(0.05)
end

function M.volume_down()
    adjust_volume(-0.05)
end

return M
