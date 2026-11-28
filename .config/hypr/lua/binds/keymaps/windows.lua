local mods = require("const.mods")
local binds = require("lib.binds")

local mm = binds.make_mod

local alt = mods.alt
local super = mods.super
local shift = mods.shift
local meh = mods.meh

local bind = hl.bind
local window = hl.dsp.window
local exec = hl.dsp.exec_cmd
local focus = hl.dsp.focus

-- Window control commands
bind(mm("Q", { alt, shift }), window.close())
bind(mm("F11", alt), window.fullscreen())
bind(mm("F", alt), window.fullscreen())
bind(mm("Q", alt), window.float({ action = "toggle" }))
bind(mm("T", alt), window.pseudo())
bind(mm("J", alt), hl.dsp.layout("togglesplit"))
bind(mm("Tab", super), exec("hyprctl dispatch toggleswallow"))
bind(mm("I", super), exec("hyprctl dispatch invertactivewindow"))

-- Window focus and workspace navigation
bind(mm("Tab", alt), focus({ last = true }))

-- Moving window focus between windows
bind(mm("h", alt), focus({ direction = "left" }))
bind(mm("l", alt), focus({ direction = "right" }))
bind(mm("k", alt), focus({ direction = "up" }))
bind(mm("j", alt), focus({ direction = "down" }))

-- Moving window focus between monitors
bind(mm("H", meh), focus({ monitor = "left" }))
bind(mm("L", meh), focus({ monitor = "right" }))

-- Move/Resize windows with the mouse
bind(mm("mouse:272", alt), window.drag(), { mouse = true })
bind(mm("mouse:273", alt), window.resize(), { mouse = true })

-- Swap windows
bind(mm("L", { alt, shift }), window.swap({ direction = "right" }))
bind(mm("H", { alt, shift }), window.swap({ direction = "left" }))
bind(mm("K", { alt, shift }), window.swap({ direction = "up" }))
bind(mm("J", { alt, shift }), window.swap({ direction = "down" }))
