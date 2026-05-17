local ram = require("functions.ram")

local exec = hl.exec_cmd
local on = hl.on

on("hyprland.start", function()
    -- Terminal
    -- kitty
    exec("[workspace 1 silent] kitty -e bash -c 'sleep 0.5 && fastfetch && bash --login'")

    -- Zen-browser
    exec("[workspace 2 silent] zen-browser")

    if ram.has_above(8) then
        -- Email
        exec("protonmail-bridge --no-window")
        exec('[workspace 6 silent] sleep 40 && hyprctl dispatch exec "[workspace 6 silent] thunderbird"')
    end

    if ram.has_above(12) then
        -- Todoist
        exec("[workspace 10 silent] sleep 5 && todoist")

        -- Ferdium
        exec("[workspace 7 silent] ferdium")
    end

    if ram.has_above(16) then
        -- Spotify
        exec("[workspace 9] bash ~/.config/hypr/scripts/spotify/open_play_silent.sh")
    end
end)
