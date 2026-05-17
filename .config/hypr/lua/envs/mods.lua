local mod_types = require("types.binds.mods")

---@class BindMods
---@field super Mods
---@field alt_l Mods
---@field shift Mods
---@field ctrl Mods
---@field alt Mods
---@field hyper string
---@field meh string

local M = {
    super = mod_types.Mods.SUPER,
    alt_l = mod_types.Mods.ALT_L,
    shift = mod_types.Mods.SHIFT,
    ctrl = mod_types.Mods.CONTROL,
    alt = mod_types.Mods.ALT,
}

M.hyper = string.format("%s + %s + %s + %s", M.alt, M.super, M.shift, M.ctrl)
M.meh = string.format("%s + %s", M.alt, M.shift, M.ctrl)

---@cast M BindMods

return M
