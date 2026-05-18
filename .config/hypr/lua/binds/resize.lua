local mods = require("envs.mods")
local binds = require("functions.binds")

local mm = binds.make_mod

local alt_l = mods.alt_l
local super = mods.super
local shift = mods.shift
local hyper = mods.hyper

local bind = hl.bind
local resize = hl.dsp.window.resize

hl.define_submap("resize", function()
    bind("L", resize({ x = 20, y = 0 }), { repeating = true })
    bind("H", resize({ x = -20, y = 0 }), { repeating = true })
    bind("K", resize({ x = 0, y = -20 }), { repeating = true })
    bind("J", resize({ x = 0, y = 20 }), { repeating = true })

    bind(mm("L", alt_l), resize({ x = 60, y = 0 }), { repeating = true })
    bind(mm("H", alt_l), resize({ x = -60, y = 0 }), { repeating = true })
    bind(mm("K", alt_l), resize({ x = 0, y = -60 }), { repeating = true })
    bind(mm("J", alt_l), resize({ x = 0, y = 60 }), { repeating = true })

    bind(mm("L", shift), resize({ x = 120, y = 0 }), { repeating = true })
    bind(mm("H", shift), resize({ x = -120, y = 0 }), { repeating = true })
    bind(mm("K", shift), resize({ x = 0, y = -120 }), { repeating = true })
    bind(mm("J", shift), resize({ x = 0, y = 120 }), { repeating = true })

    bind(mm("L", super), resize({ x = 240, y = 0 }), { repeating = true })
    bind(mm("H", super), resize({ x = -240, y = 0 }), { repeating = true })
    bind(mm("K", super), resize({ x = 0, y = -240 }), { repeating = true })
    bind(mm("J", super), resize({ x = 0, y = 240 }), { repeating = true })

    bind(mm("L", hyper), resize({ x = 500, y = 0 }), { repeating = true })
    bind(mm("H", hyper), resize({ x = -500, y = 0 }), { repeating = true })
    bind(mm("K", hyper), resize({ x = 0, y = -500 }), { repeating = true })
    bind(mm("J", hyper), resize({ x = 0, y = 500 }), { repeating = true })

    bind(mm("R", super), hl.dsp.submap("reset"))
end)

bind(mm("R", super), hl.dsp.submap("resize"))
