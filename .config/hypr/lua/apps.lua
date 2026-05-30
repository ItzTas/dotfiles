local ram = require("functions.ram")
local utils = require("functions.utils")
local spotify = require("scripts.spotify")

local exec = hl.exec_cmd
local on = hl.on

on("hyprland.start", function()
    -- Terminal
    -- kitty
    exec("kitty -e bash -c 'sleep 0.5 && fastfetch && bash --login'", { workspace = "1 silent" })

    -- Zen-browser
    exec("zen-browser", { workspace = "2 silent" })

    if ram.has_above(8) then
        -- Email
        exec("protonmail-bridge --no-window")

        utils.defer(function()
            exec("thunderbird", { workspace = "6 silent" })
        end, 40000)
    end

    if ram.has_above(12) then
        -- Ferdium
        exec("ferdium", { workspace = "7 silent" })

        -- Todoist
        utils.defer(function()
            exec("todoist", { workspace = "10 silent" })
        end, 5000)
    end

    if ram.has_above(16) then
        -- Spotify
        spotify.open_play_silent()
    end
end)
