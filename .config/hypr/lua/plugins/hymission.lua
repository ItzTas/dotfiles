if not hl.plugin.hymission then
    return
end

local binds = require("functions.binds")
local mods = require("envs.mods")

local mm = binds.make_mod

local super = mods.super
local alt = mods.alt
local super_l = mods.super_l

local hymission = hl.plugin.hymission
local bind = hl.bind

bind(mm("A", alt), function()
    hymission.toggle("forceall")
end)
bind(mm("S", super), function()
    hymission.open("onlycurrentworkspace")
end)
bind(mm("Escape", super), hymission.close)

local open_bind
local close_bind
local enable_close_bind

local function enable_open_bind()
    open_bind = bind(super_l, function()
        open_bind:remove()
        enable_close_bind()
        hymission.open()
<<<<<<< HEAD
    end, {
        long_press = true
    })
||||||| parent of a2f38fed6 (2026-05-21 21:33 - Updated: M ../../hypr/lua/functions/binds.lua,M ../../hypr/lua/plugins/hymission.lua,D ../bootstrap.x.d/set_up/git.sh,M ../bootstrap.x.d/set_up/zen-browser.sh,)
    end)
=======
    end, {
        long_press = true,
    })
>>>>>>> a2f38fed6 (2026-05-21 21:33 - Updated: M ../../hypr/lua/functions/binds.lua,M ../../hypr/lua/plugins/hymission.lua,D ../bootstrap.x.d/set_up/git.sh,M ../bootstrap.x.d/set_up/zen-browser.sh,)
end

function enable_close_bind()
    close_bind = bind(super_l, function()
        close_bind:remove()
        enable_open_bind()
        hymission.close()
    end)
end

enable_open_bind()
