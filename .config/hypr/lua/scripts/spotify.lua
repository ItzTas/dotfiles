local utils = require("functions.utils")
local notify = require("envs.notify")

local ICON_DIR = notify.ICON_DIR
local REPLACE_ID = notify.REPLACE_ID

local M = {}

function M.next()
    utils.run_async_cmd("playerctl -p spotifast next")
end

function M.prev()
    utils.run_async_cmd("playerctl -p spotifast previous")
end

function M.open_play()
    hl.exec_cmd("spotifast", { workspace = 9 })
    utils.defer(function()
        utils.run_cmd("playerctl -p spotifast play")
    end, 800)
end

function M.open_play_silent()
    hl.exec_cmd("spotifast", {
        workspace = "9 silent",
    })

    utils.defer(function()
        utils.run_cmd(
            "count=0; "
            .. 'until playerctl -l 2>/dev/null | grep -q spotifast || [ "$count" -ge 20 ]; do '
            .. "sleep 0.5; count=$((count+1)); done; "
            .. "sleep 2; "
            .. "playerctl -p spotifast volume 0 2>/dev/null; "
            .. "playerctl -p spotifast play 2>/dev/null"
        )
    end)
end

---@param delta number
local function adjust_volume(delta)
    local sign = delta >= 0 and "+" or "-"
    local abs_val = string.format("%.2f", math.abs(delta))

    utils.run_async_cmd(
        string.format(
            "status=$(playerctl -p spotifast status 2>&1);"
            .. ' if echo "$status" | grep -q "No players found" || [ -z "$status" ]; then exit 0; fi;'
            .. " current=$(playerctl -p spotifast volume);"
            .. " new=$(awk -v v=\"$current\" 'BEGIN { v=v%s%s; if(v>1) v=1; if(v<0) v=0; print v }');"
            .. ' playerctl -p spotifast volume "$new";'
            .. " vol=$(awk -v v=\"$new\" 'BEGIN { print int(v*100 + 0.5) }');"
            .. ' notify-send -e -h "int:value:$vol" -i "%s/volume.svg" -t 500 -r %d "Spotify: $vol%%"',
            sign,
            abs_val,
            ICON_DIR,
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
