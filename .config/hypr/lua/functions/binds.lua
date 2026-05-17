local M = {}

---@alias MakeModFn fun(k: string, mods: (Mods|string)[]|Mods|string|nil): string

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
---@param k string
---@param mods (Mods|string)[]|Mods|string|nil
---@return string
function M.make_mod(k, mods)
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

return M
