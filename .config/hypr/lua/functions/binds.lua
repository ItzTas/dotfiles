local M = {}

---@alias MakeModFn fun(k: string|integer, mods: (Mods|string)[]|Mods|string|nil): string

---@type table<table, string>
local mods_join_cache = {}

---@param mods (Mods|string)[]
---@return string
local function join_mods(mods)
    local cached = mods_join_cache[mods]
    if cached then
        return cached
    end

    local result = table.concat(mods, " + ")
    mods_join_cache[mods] = result
    return result
end

---@param k string
---@param mods (Mods|string)[]
---@return string
local function make_mod_table(k, mods)
    return string.format("%s + %s", join_mods(mods), k)
end

---@param k string
---@param mods string
---@return string
local function make_mod_string(k, mods)
    return string.format("%s + %s", mods, k)
end

---@type MakeModFn
---@param k string|integer
---@param mods (Mods|string)[]|Mods|string|nil
---@return string
function M.make_mod(k, mods)
    if type(k) ~= "string" then
        k = tostring(k)
    end
    if not mods or #mods == 0 then
        return k
    end

    local mod_type = type(mods)

    if mod_type == "string" then
        return make_mod_string(k, mods)
    end

    if mod_type == "table" then
        return make_mod_table(k, mods)
    end

    return k
end

---@param base table
---@param overrides table
---@return table
local function merge_opts(base, overrides)
    local result = {}
    for k, v in pairs(base) do
        result[k] = v
    end
    for k, v in pairs(overrides) do
        result[k] = v
    end
    return result
end

---@type table
M.scratchpad_opts = {
    float = true,
    no_blur = true,
    size = { "(monitor_w*0.9)", "(monitor_h*0.8)" },
}

---@param key string
---@param cmd string
---@param opts? HL.BindOptions
function M.bind_scratchpad(key, cmd, opts)
    local merged = merge_opts(M.scratchpad_opts, opts or {})
    hl.bind(key, hl.dsp.exec_cmd(cmd, merged))
end



---@class HoldActions
---@field tap? any
---@field hold? any
---@field release? any

---@param key string
---@param actions HoldActions
---@param opts? table
function M.bind_hold(key, actions, opts)
    opts = opts or {}

    if actions.hold then
        hl.bind(key, actions.hold, merge_opts(opts, { long_press = true }))
    end

    if actions.tap then
        hl.bind(key, actions.tap, opts)
    end

    if actions.release then
        hl.bind(key, actions.release, merge_opts(opts, { release = true }))
    end
end

return M
