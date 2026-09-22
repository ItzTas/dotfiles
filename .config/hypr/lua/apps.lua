local ram = require("functions.ram")
local spotify = require("scripts.spotify")

local exec = hl.exec_cmd
local on = hl.on

on("hyprland.start", function()
    -- Terminal
    -- kitty
    exec("kitty -e bash -c 'sleep 0.5 && fastfetch && bash --login'", { workspace = "1 silent" })

    -- Zen-browser
    exec("zen-browser", { workspace = "2" })

    if ram.has_above(8) then
        -- Email
        exec("protonmail-bridge --no-window")

        -- Delay in the shell, not in hl.timer: a pending Lua timer is dropped on
        -- any config reload, which kills the launch before it happens.
        exec("sleep 40 && exec thunderbird", { workspace = "6 silent" })
    end

    if ram.has_above(12) then
        -- Ferdium
        exec("ferdium", { workspace = "7 silent" })

        -- Todoist
        -- exec("sleep 5 && exec todoist", { workspace = "10 silent" })
    end

    if ram.has_above(16) then
        -- Spotify
        spotify.open_play_silent()
    end
end)
