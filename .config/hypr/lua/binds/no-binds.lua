local mods = require("envs.mods")
local fb = require("functions.binds")

local hyperMod = mods.hyper
local mainMod = mods.alt

local mm = fb.make_mod

hl.bind(hyperMod .. " + I", hl.dsp.submap("no-binds"))

hl.define_submap("no-binds", function()
    -- hl.bind(hyperMod .. " + catchall", hl.dsp.submap("reset"))
    hl.bind(mm("escape", mainMod), hl.dsp.submap("reset"))
end)
