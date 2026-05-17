local mods = require("env.mods")

local mainMod = mods.mainMod
local scndMod = mods.scndMod
local shiftMod = mods.shiftMod
local hyperMod = mods.hyperMod

hl.bind(scndMod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("L", hl.dsp.window.resize("20 0"), { repeating = true })
    hl.bind("H", hl.dsp.window.resize("-20 0"), { repeating = true })
    hl.bind("K", hl.dsp.window.resize("0 -20"), { repeating = true })
    hl.bind("J", hl.dsp.window.resize("0 20"), { repeating = true })

    hl.bind(mainMod .. " + L", hl.dsp.window.resize("60 0"), { repeating = true })
    hl.bind(mainMod .. " + H", hl.dsp.window.resize("-60 0"), { repeating = true })
    hl.bind(mainMod .. " + K", hl.dsp.window.resize("0 -60"), { repeating = true })
    hl.bind(mainMod .. " + J", hl.dsp.window.resize("0 60"), { repeating = true })

    hl.bind(shiftMod .. " + L", hl.dsp.window.resize("120 0"), { repeating = true })
    hl.bind(shiftMod .. " + H", hl.dsp.window.resize("-120 0"), { repeating = true })
    hl.bind(shiftMod .. " + K", hl.dsp.window.resize("0 -120"), { repeating = true })
    hl.bind(shiftMod .. " + J", hl.dsp.window.resize("0 120"), { repeating = true })

    hl.bind(scndMod .. " + L", hl.dsp.window.resize("240 0"), { repeating = true })
    hl.bind(scndMod .. " + H", hl.dsp.window.resize("-240 0"), { repeating = true })
    hl.bind(scndMod .. " + K", hl.dsp.window.resize("0 -240"), { repeating = true })
    hl.bind(scndMod .. " + J", hl.dsp.window.resize("0 240"), { repeating = true })

    hl.bind(hyperMod .. " + L", hl.dsp.window.resize("500 0"), { repeating = true })
    hl.bind(hyperMod .. " + H", hl.dsp.window.resize("-500 0"), { repeating = true })
    hl.bind(hyperMod .. " + K", hl.dsp.window.resize("0 -500"), { repeating = true })
    hl.bind(hyperMod .. " + J", hl.dsp.window.resize("0 500"), { repeating = true })

    hl.bind(scndMod .. " + R", hl.dsp.submap("reset"))
end)
