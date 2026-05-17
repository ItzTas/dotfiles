-- Variables
local terminal    = "kitty"
local fileManager = "nemo"
local browser     = "zen-browser"

-- Modifiers
local mainMod  = "LEFTALT"
local scndMod  = "SUPER"
local shiftMod = "SHIFT"
local ctrlMod  = "CONTROL"
local hyperMod = "LEFTALT SUPER SHIFT CONTROL"

-- Open terminal and navigation
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(hyperMod .. " + return", hl.dsp.exec_cmd("[workspace special:magic] " .. terminal))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(fileManager))

-- Window control commands
hl.bind(mainMod .. " " .. shiftMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F11", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + Q", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("$menu"))
hl.bind(mainMod .. " + T", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(scndMod .. " + Tab", hl.dsp.exec_cmd("hyprctl dispatch toggleswallow"))

-- Plugins
hl.bind(scndMod .. " + I", hl.dsp.exec_cmd("hyprctl dispatch invertactivewindow"))
hl.bind(scndMod .. " + T", hl.dsp.exec_cmd("hyprctl dispatch hyprexpo:expo toggle"))

-- Specific workspace and multimedia commands
hl.bind(hyperMod .. " + B", hl.dsp.exec_cmd("[workspace 8] stacer"))
hl.bind(hyperMod .. " + Z", hl.dsp.exec_cmd("[workspace 8] hyprctl dispatch workspace 8; easyeffects"))

-- Spotify
hl.bind(hyperMod .. " + Q", hl.dsp.exec_cmd('[workspace 9] bash "$HOME/.config/hypr/scripts/spotify/open_play.sh"'))
hl.bind(scndMod .. " + F", hl.dsp.exec_cmd('[workspace 9] bash "$HOME/.config/hypr/scripts/spotify/next.sh"'))
hl.bind(scndMod .. " + D", hl.dsp.exec_cmd('[workspace 9] bash "$HOME/.config/hypr/scripts/spotify/prev.sh"'))

-- Window focus and workspace navigation
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ cycle = "next" }))

-- Scratchpad (temporary windows)
hl.bind(hyperMod .. " + D", hl.dsp.exec_cmd("dex ~/.local/share/applications/hypr-terminal/hypr-lazydocker.desktop"))
hl.bind(hyperMod .. " + P", hl.dsp.exec_cmd("dex ~/.local/share/applications/hypr-terminal/hypr-ncdu.desktop"))
hl.bind(hyperMod .. " + H", hl.dsp.exec_cmd("dex ~/.local/share/applications/hypr-terminal/hypr-btop.desktop"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("[float; noblur 0; size 90% 80%] kitty -o background_opacity=0.9 -e yazi"))
hl.bind(hyperMod .. " + O", hl.dsp.exec_cmd("[float; size 90% 80%] kitty -o background_opacity=1 -e gping google.com"))
hl.bind(hyperMod .. " + S", hl.dsp.exec_cmd('[float; noblur 0; noborder 0; size 90% 80%] kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh"'))
hl.bind(hyperMod .. " + A", hl.dsp.exec_cmd('[float; noblur 0; noborder 0;size 90% 80%] kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" root'))
hl.bind(hyperMod .. " + F", hl.dsp.exec_cmd('[float; noblur 0; noborder 0; size 90% 80%] kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" file'))
hl.bind(hyperMod .. " + G", hl.dsp.exec_cmd('[float; noblur 0; noborder 0;size 90% 80%] kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" file root'))

-- Menus and widgets
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd('killall rofi; bash -c "~/.config/rofi/launchers/type-7/launcher.sh"'))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("killall rofi; wlogout"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dex ~/.local/share/applications/hypr-terminal/hypr-clipse.desktop"))
hl.bind(scndMod .. " + V", hl.dsp.exec_cmd("clipse-gui"))
hl.bind(hyperMod .. " + SPACE", hl.dsp.exec_cmd('killall rofi; bash -c "~/.config/rofi/emoji/emoji.sh"'))

-- Moving window focus between windows
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + numbers
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " " .. shiftMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Switch workspaces with scndMod + numbers (11-20)
for i = 1, 10 do
    local key = i % 10
    hl.bind(scndMod .. " + " .. key, hl.dsp.focus({ workspace = i + 10 }))
    hl.bind(scndMod .. " " .. shiftMod .. " + " .. key, hl.dsp.window.move({ workspace = i + 10 }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + U", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " " .. shiftMod .. " + U", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll to navigate between workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/Resize windows with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Swap windows
hl.bind(mainMod .. " " .. shiftMod .. " + l", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " " .. shiftMod .. " + h", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " " .. shiftMod .. " + k", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " " .. shiftMod .. " + j", hl.dsp.window.swap({ direction = "down" }))

-- Multimedia controls (volume and brightness)
hl.bind(shiftMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/spotify/volume_up.sh"), { repeating = true })
hl.bind(shiftMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("bash ~/.config/hypr/scripts/spotify/volume_down.sh"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/volume/up.sh"'), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/volume/down.sh"'), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/volume/toggle.sh"'))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/mic_toggle.sh"'))

-- Brightness control
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true })

-- Multimedia control with playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screen recording
hl.bind(mainMod .. " " .. shiftMod .. " + G", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/recording/screen_record.sh"'))

-- Screenshots
hl.bind("PRINT", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/print/screen.sh"'))
hl.bind(shiftMod .. " + PRINT", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/print/area.sh"'))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/print/window.sh"'))
hl.bind(scndMod .. " + PRINT", hl.dsp.exec_cmd("flameshot gui"))

-- Scripts
-- hl.bind(hyperMod .. " + T", hl.dsp.exec_cmd('bash -c "~/.config/hypr/scripts/toggle_hdr.sh"'))

-- Browsing
hl.bind(hyperMod .. " + R", hl.dsp.exec_cmd(browser .. " https://www.startpage.com"))
hl.bind(hyperMod .. " + E", hl.dsp.exec_cmd(browser .. " https://translate.google.com/?sl=auto&tl=pt"))

-- Others
hl.bind(hyperMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(hyperMod .. " + X", hl.dsp.exec_cmd("ddcutil setvcp 10 100"))
hl.bind(hyperMod .. " + W", hl.dsp.exec_cmd("alarm-clock-applet -s"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd('killall waybar || bash -c "~/.config/waybar/lauch_waybar.sh 2"'))
hl.bind(scndMod .. " " .. shiftMod .. " + F5", hl.dsp.exit())

-- --- Submaps ---

-- Resize windows
hl.bind(scndMod .. " + R", hl.dsp.submap("resize"))

hl.submap("resize")

hl.bind("L", hl.dsp.window.resize({ x = 20, y = 0 }), { repeating = true })
hl.bind("H", hl.dsp.window.resize({ x = -20, y = 0 }), { repeating = true })
hl.bind("K", hl.dsp.window.resize({ x = 0, y = -20 }), { repeating = true })
hl.bind("J", hl.dsp.window.resize({ x = 0, y = 20 }), { repeating = true })

hl.bind(mainMod .. " + L", hl.dsp.window.resize({ x = 60, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + H", hl.dsp.window.resize({ x = -60, y = 0 }), { repeating = true })
hl.bind(mainMod .. " + K", hl.dsp.window.resize({ x = 0, y = -60 }), { repeating = true })
hl.bind(mainMod .. " + J", hl.dsp.window.resize({ x = 0, y = 60 }), { repeating = true })

hl.bind(shiftMod .. " + L", hl.dsp.window.resize({ x = 120, y = 0 }), { repeating = true })
hl.bind(shiftMod .. " + H", hl.dsp.window.resize({ x = -120, y = 0 }), { repeating = true })
hl.bind(shiftMod .. " + K", hl.dsp.window.resize({ x = 0, y = -120 }), { repeating = true })
hl.bind(shiftMod .. " + J", hl.dsp.window.resize({ x = 0, y = 120 }), { repeating = true })

hl.bind(scndMod .. " + L", hl.dsp.window.resize({ x = 240, y = 0 }), { repeating = true })
hl.bind(scndMod .. " + H", hl.dsp.window.resize({ x = -240, y = 0 }), { repeating = true })
hl.bind(scndMod .. " + K", hl.dsp.window.resize({ x = 0, y = -240 }), { repeating = true })
hl.bind(scndMod .. " + J", hl.dsp.window.resize({ x = 0, y = 240 }), { repeating = true })

hl.bind(hyperMod .. " + L", hl.dsp.window.resize({ x = 500, y = 0 }), { repeating = true })
hl.bind(hyperMod .. " + H", hl.dsp.window.resize({ x = -500, y = 0 }), { repeating = true })
hl.bind(hyperMod .. " + K", hl.dsp.window.resize({ x = 0, y = -500 }), { repeating = true })
hl.bind(hyperMod .. " + J", hl.dsp.window.resize({ x = 0, y = 500 }), { repeating = true })

hl.bind(scndMod .. " + R", hl.dsp.submap("reset"))

hl.submap("reset")

-- No bindings submap
hl.bind(hyperMod .. " + I", hl.dsp.submap("no_bindings"))

hl.submap("no_bindings")

hl.bind(hyperMod .. " + catchall", hl.dsp.submap("reset"))

hl.submap("reset")
