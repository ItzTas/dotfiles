-- Terminal
-- kitty
hl.exec_once("[workspace 1 silent] kitty -e bash -c 'sleep 0.5 && fastfetch && bash --login'")

-- Zen-browser
hl.exec_once("[workspace 2 silent] zen-browser")

-- Email
hl.exec_once("protonmail-bridge --no-window")
hl.exec_once('[workspace 6 silent] sleep 40 && hyprctl dispatch exec "[workspace 6 silent] thunderbird"')

-- Todoist
hl.exec_once("[workspace 10 silent] sleep 5 && todoist")

-- Ferdium
hl.exec_once("[workspace 7 silent] ferdium")

-- Spotify
hl.exec_once("[workspace 9] bash ~/.config/hypr/scripts/spotify/open_play_silent.sh")
