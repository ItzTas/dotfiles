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
    hl.exec_cmd("sleep 3 && exec spotifast --start-hidden", {
        workspace = "9 silent",
    })

    utils.run_async_cmd([[
out=""; count=0
until [ -n "$out" ] || [ "$count" -ge 40 ]; do
    sleep 0.5; count=$((count+1))
    out=$(pw-dump 2>/dev/null | jq -r 'first(.[] | select(.info.props["node.name"]? // "" | test("^spotifast\\.soloist\\..*\\.output$")) | .id) // empty')
done
[ -n "$out" ] || exit 0
wpctl set-mute "$out" 1
trap 'wpctl set-mute "$out" 0' EXIT

id=""; count=0
until [ -n "$id" ] || [ "$count" -ge 30 ]; do
    sleep 0.5; count=$((count+1))
    device=$(ps -o args= -C soloist | sed -n 's/.*--device-name \(.*\) --api-key.*/\1/p' | head -1)
    [ -n "$device" ] || continue
    id=$(spotifast devices 2>/dev/null | grep -F "$device" | grep -oE "[0-9a-f-]{36}")
done
[ -n "$id" ] || exit 0

ok=0
for _ in $(seq 60); do
    if [ "$(playerctl -p spotifast status 2>/dev/null)" != Playing ]; then
        ok=0
        spotifast devices 2>/dev/null | grep -q "^\* $id" || { spotifast transfer "$id"; sleep 2.5; }
        spotifast play; sleep 1; continue
    fi
    if [ "$(playerctl -p spotifast volume 2>/dev/null)" != 0.000000 ]; then
        ok=0; spotifast volume 0; sleep 0.5; continue
    fi
    ok=$((ok+1)); [ "$ok" -ge 10 ] && exit 0
    sleep 0.5
done
spotifast pause
]])
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
