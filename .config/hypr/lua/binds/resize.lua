local mods = require("envs.mods")
local binds = require("functions.binds")

local mm = binds.make_mod

local mainMod = mods.alt_l
local scndMod = mods.super
local shiftMod = mods.shift
local hyperMod = mods.hyper

local bind = hl.bind
local resize = hl.dsp.window.resize

bind(mm("R", scndMod), hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    bind("L", function()
        resize("20 0")
    end, { repeating = true })
    bind("H", function()
        resize("-20 0")
    end, { repeating = true })
    bind("K", function()
        resize("0 -20")
    end, { repeating = true })
    bind("J", function()
        resize("0 20")
    end, { repeating = true })

    bind(mm("L", mainMod), function()
        resize("60 0")
    end, { repeating = true })
    bind(mm("H", mainMod), function()
        resize("-60 0")
    end, { repeating = true })
    bind(mm("K", mainMod), function()
        resize("0 -60")
    end, { repeating = true })
    bind(mm("J", mainMod), function()
        resize("0 60")
    end, { repeating = true })

    bind(mm("L", shiftMod), function()
        resize("120 0")
    end, { repeating = true })
    bind(mm("H", shiftMod), function()
        resize("-120 0")
    end, { repeating = true })
    bind(mm("K", shiftMod), function()
        resize("0 -120")
    end, { repeating = true })
    bind(mm("J", shiftMod), function()
        resize("0 120")
    end, { repeating = true })

    bind(mm("L", scndMod), function()
        resize("240 0")
    end, { repeating = true })
    bind(mm("H", scndMod), function()
        resize("-240 0")
    end, { repeating = true })
    bind(mm("K", scndMod), function()
        resize("0 -240")
    end, { repeating = true })
    bind(mm("J", scndMod), function()
        resize("0 240")
    end, { repeating = true })

    bind(mm("L", hyperMod), function()
        resize("500 0")
    end, { repeating = true })
    bind(mm("H", hyperMod), function()
        resize("-500 0")
    end, { repeating = true })
    bind(mm("K", hyperMod), function()
        resize("0 -500")
    end, { repeating = true })
    bind(mm("J", hyperMod), function()
        resize("0 500")
    end, { repeating = true })

    bind(mm("R", scndMod), hl.dsp.submap("reset"))
end)
