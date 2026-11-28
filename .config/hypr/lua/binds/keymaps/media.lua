local mods = require("const.mods")
local binds = require("lib.binds")
local volume = require("actions.volume")
local mic = require("actions.mic")
local spotify = require("actions.spotify")

local mm = binds.make_mod

local super = mods.super
local shift = mods.shift
local meh = mods.meh

local bind = hl.bind
local exec = hl.dsp.exec_cmd

-- Spotify
bind(mm("Q", meh), spotify.open_play)
bind(mm("F", super), spotify.next)
bind(mm("D", super), spotify.prev)

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
