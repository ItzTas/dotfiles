local mods = require("envs.mods")
local apps = require("envs.apps")
local binds = require("functions.binds")

local volume = require("scripts.volume")
local mic = require("scripts.mic")
local spotify = require("scripts.spotify")
local print = require("scripts.print")
local recording = require("scripts.recording")

local mm = binds.make_mod
local bs = binds.bind_scratchpad

local alt = mods.alt
local super = mods.super
local shift = mods.shift
local meh = mods.meh
local _ = mods.hyper

local terminal = apps.terminal
local fileManager = apps.fileManager
local browser = apps.browser

local bind = hl.bind
local window = hl.dsp.window
local exec = hl.dsp.exec_cmd
local focus = hl.dsp.focus
local workspace = hl.dsp.workspace

-- Open terminal and navigation
bind(mm("return", alt), exec(terminal))
bind(mm("return", meh), exec(terminal, { workspace = "special:magic" }))
bind(mm("B", alt), exec(fileManager))

-- Window control commands
bind(mm("Q", { alt, shift }), window.close())
bind(mm("F11", alt), window.fullscreen())
bind(mm("F", alt), window.fullscreen())
bind(mm("Q", alt), window.float({ action = "toggle" }))
bind(mm("R", alt), exec("$menu"))
bind(mm("T", alt), window.pseudo())
bind(mm("J", alt), hl.dsp.layout("togglesplit"))
bind(mm("Tab", super), exec("hyprctl dispatch toggleswallow"))

-- Plugins
bind(mm("I", super), exec("hyprctl dispatch invertactivewindow"))
bind(mm("T", super), exec("hyprctl dispatch hyprexpo:expo toggle"))

-- Specific workspace and multimedia commands
bind(mm("B", meh), exec("stacer", { workspace = 8 }))
bind(mm("Z", meh), exec("hyprctl dispatch workspace 8; easyeffects", { workspace = 8 }))

-- Spotify
bind(mm("Q", meh), spotify.open_play)
bind(mm("F", super), spotify.next)
bind(mm("D", super), spotify.prev)

-- Window focus and workspace navigation
bind(mm("Tab", alt), focus({ last = true }))

-- Scratchpad (temporary windows)
bind(mm("D", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-lazydocker.desktop"))
bind(mm("P", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-ncdu.desktop"))
bind(mm("H", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-btop.desktop"))
bs(mm("A", alt), "kitty -o background_opacity=0.9 -e yazi", { no_blur = false })
bs(mm("O", meh), "kitty -o background_opacity=1 -e gping google.com")
bs(mm("S", meh), 'kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh"')
bs(mm("A", meh), 'kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" root')
bs(mm("F", meh), 'kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" file')
bs(mm("G", meh), 'kitty -o background_opacity=0.65 -e bash "$HOME/.config/hypr/scripts/fzf/fzf_explorer.sh" file root')

-- Menus and widgets
bind(mm("SPACE", alt), exec('qs -c noctalia-shell ipc call launcher toggle'))
bind(mm("X", alt), exec("killall wlogout || wlogout"))
bind(mm("V", alt), exec("dex ~/.local/share/applications/hypr-terminal/hypr-clipse.desktop"))
bind(mm("V", super), exec("clipse-gui"))
bind(mm("SPACE", meh), exec('killall rofi; bash -c "~/.config/rofi/emoji/emoji.sh"'))

-- Moving window focus between windows
bind(mm("h", alt), focus({ direction = "left" }))
bind(mm("l", alt), focus({ direction = "right" }))
bind(mm("k", alt), focus({ direction = "up" }))
bind(mm("j", alt), focus({ direction = "down" }))

-- Moving window focus between monitors
bind(mm("H", meh), focus({ monitor = "left" }))
bind(mm("L", meh), focus({ monitor = "right" }))

-- Switch workspaces with mainMod + numbers
for i = 1, 10 do
    local key = i % 10
    bind(mm(key, alt), focus({ workspace = i }))
    bind(mm(key, { alt, shift }), window.move({ workspace = i }))
end

-- Switch workspaces with scndMod + numbers (11-20)
for i = 1, 10 do
    local key = i % 10
    bind(mm(key, super), focus({ workspace = i + 10 }))
    bind(mm(key, { super, shift }), window.move({ workspace = i + 10 }))
end

-- Special workspace (scratchpad)
bind(mm("U", alt), workspace.toggle_special("magic"))
bind(mm("U", { alt, shift }), window.move({ workspace = "special:magic" }))

-- Scroll to navigate between workspaces
bind(mm("mouse_down", alt), focus({ workspace = "e+1" }))
bind(mm("mouse_up", alt), focus({ workspace = "e-1" }))

-- Move/Resize windows with the mouse
bind(mm("mouse:272", alt), window.drag(), { mouse = true })
bind(mm("mouse:273", alt), window.resize(), { mouse = true })

-- Swap windows
bind(mm("L", { alt, shift }), window.swap({ direction = "right" }))
bind(mm("H", { alt, shift }), window.swap({ direction = "left" }))
bind(mm("K", { alt, shift }), window.swap({ direction = "up" }))
bind(mm("J", { alt, shift }), window.swap({ direction = "down" }))

-- Multimedia controls (volume and brightness)
bind(mm("XF86AudioRaiseVolume", shift), spotify.volume_up, { repeating = true })
bind(mm("XF86AudioLowerVolume", shift), spotify.volume_down, { repeating = true })
bind("XF86AudioRaiseVolume", function()
    volume.adjust(5)
end, { repeating = true })
bind("XF86AudioLowerVolume", function()
    volume.adjust(-5)
end, { repeating = true })
bind("XF86AudioMute", volume.toggle_mute)
bind("XF86AudioMicMute", mic.toggle_mute)

-- Brightness control
bind("XF86MonBrightnessUp", exec("brightnessctl set +5%"), { repeating = true })
bind("XF86MonBrightnessDown", exec("brightnessctl set 5%-"), { repeating = true })

-- Multimedia control with playerctl
bind("XF86AudioNext", exec("playerctl next"), { locked = true })
bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })

-- Screen recording
bind(mm("G", { alt, shift }), recording.toggle)

-- Screenshots
bind("PRINT", print.screen)
bind(mm("PRINT", shift), print.area)
bind(mm("PRINT", alt), print.window)
bind(mm("PRINT", super), exec("flameshot gui"))

-- Scripts
-- local hdr = require("scripts.hdr")
-- bind(mm("T", hyperMod), hdr.toggle)

-- Browsing
bind(mm("R", meh), exec(browser .. " https://www.startpage.com"))
bind(mm("E", meh), exec(browser .. " https://translate.google.com/?sl=auto&tl=pt"))

-- Others
bind(mm("C", meh), exec("hyprpicker -a"))
bind(mm("X", meh), exec("ddcutil setvcp 10 100"))
bind(mm("W", meh), exec("alarm-clock-applet -s"))
bind(mm("W", alt), exec('killall qs || qs -c noctalia-shell'))
bind(mm("F5", { super, shift }), hl.dsp.exit())
bind(mm("L", meh), exec("pidof hyprlock || hyprlock -c ~/.config/hypr/hyprlock/mocha/hyprlock.conf"))
