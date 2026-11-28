local mods = require("const.mods")
local binds = require("lib.binds")

local mm = binds.make_mod

local alt = mods.alt
local super = mods.super
local shift = mods.shift

local bind = hl.bind
local window = hl.dsp.window
local exec = hl.dsp.exec_cmd
local focus = hl.dsp.focus
local workspace = hl.dsp.workspace

bind(mm("T", super), exec("hyprctl dispatch hyprexpo:expo toggle"))

-- Switch workspaces with mainMod + numbers
for i = 1, 10 do
    local key = i % 10
    bind(mm(key, alt), focus({ workspace = i }))
    bind(mm(key, { alt, shift }), window.move({ workspace = i }))
end

-- Switch workspaces with scndMod + numbers (11-20)
for i = 1, 10 do
    local key = i % 10
    bind(mm(key, super), focus({ workspace = i + 10 }))
    bind(mm(key, { super, shift }), window.move({ workspace = i + 10 }))
end

-- Special workspace (scratchpad)
bind(mm("U", alt), workspace.toggle_special("magic"))
bind(mm("U", { alt, shift }), window.move({ workspace = "special:magic" }))

-- Scroll to navigate between workspaces
bind(mm("mouse_down", alt), focus({ workspace = "e+1" }))
bind(mm("mouse_up", alt), focus({ workspace = "e-1" }))
