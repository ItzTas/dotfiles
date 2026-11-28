local mods = require("const.mods")
local binds = require("lib.binds")

local mm = binds.make_mod

local super = mods.super

local bind = hl.bind
local resize = hl.dsp.window.resize

bind(mm("R", super), hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    local directions = {
        L = { 1, 0 },
        H = { -1, 0 },
        K = { 0, -1 },
        J = { 0, 1 },
    }

    local steps = {
        { mod = nil, px = 20 },
        { mod = mods.alt_l, px = 60 },
        { mod = mods.shift, px = 120 },
        { mod = super, px = 240 },
        { mod = mods.hyper, px = 500 },
    }

    for _, step in ipairs(steps) do
        for key, dir in pairs(directions) do
            local dsp = resize({ x = dir[1] * step.px, y = dir[2] * step.px, relative = true })
            bind(mm(key, step.mod), dsp, { repeating = true })
        end
    end

    bind(mm("R", super), hl.dsp.submap("reset"))
    bind("escape", hl.dsp.submap("reset"))
end)
