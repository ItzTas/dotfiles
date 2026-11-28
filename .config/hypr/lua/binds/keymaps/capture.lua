local mods = require("const.mods")
local binds = require("lib.binds")
local print = require("actions.print")
local recording = require("actions.recording")

local mm = binds.make_mod

local alt = mods.alt
local super = mods.super
local shift = mods.shift

local bind = hl.bind
local exec = hl.dsp.exec_cmd

-- Screen recording
bind(mm("G", { alt, shift }), recording.toggle)

-- Screenshots
bind("PRINT", print.screen)
bind(mm("PRINT", shift), print.area)
bind(mm("PRINT", alt), print.window)
bind(mm("PRINT", super), exec("flameshot gui"))
