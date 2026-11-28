local mods = require("const.mods")
local binds = require("lib.binds")
local input = require("actions.input")
local noctalia = require("actions.noctalia")

local mm = binds.make_mod

local alt = mods.alt
local super = mods.super
local shift = mods.shift
local meh = mods.meh

local bind = hl.bind
local exec = hl.dsp.exec_cmd

-- Scripts
-- local hdr = require("actions.hdr")
-- bind(mm("T", hyperMod), hdr.toggle)

-- Devices
bind(mm("T", meh), function()
    input.toggle("asue1200:00-04f3:3288-touchpad", { label = "Touchpad", icon = "input-touchpad" })
end)

-- Others
bind(mm("C", meh), exec("hyprpicker -a"))
bind(mm("X", meh), exec("ddcutil setvcp 10 100"))
bind(mm("W", meh), exec("alarm-clock-applet -s"))
bind(mm("W", alt), noctalia.toggle)
bind(mm("F5", { super, shift }), hl.dsp.exit())
bind(mm("L", meh), exec(noctalia.msg("session lock")))
