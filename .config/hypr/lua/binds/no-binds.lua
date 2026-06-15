local mods = require("envs.mods")
local fb = require("functions.binds")

local alt_l = mods.alt_l
local super = mods.super
local meh = mods.meh

local mm = fb.make_mod

hl.bind(mm("I", meh), hl.dsp.submap("no-binds"))

hl.define_submap("no-binds", function()
    -- hl.bind(mm("catchall", meh), hl.dsp.submap("reset"))
    hl.bind(mm("escape", alt_l), hl.dsp.submap("reset"))
    hl.bind(mm("I", super), hl.dsp.submap("reset"))
end)
