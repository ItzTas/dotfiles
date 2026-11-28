local utils = require("lib.utils")
local shell = require("lib.shell")

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
    shell.run("spotify/silent_start")
end

---@param delta number
local function adjust_volume(delta)
    shell.run("spotify/volume", { args = { delta } })
end

function M.volume_up()
    adjust_volume(0.05)
end

function M.volume_down()
    adjust_volume(-0.05)
end

return M
