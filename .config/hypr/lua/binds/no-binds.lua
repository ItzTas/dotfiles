local mods = require("env.mods")

local hyperMod = mods.hyperMod

hl.bind(hyperMod .. " + I", hl.dsp.submap("no-binds"))

hl.define_submap("no-binds", function()
    hl.bind(hyperMod .. " + catchall", hl.dsp.submap("reset"))
end)
