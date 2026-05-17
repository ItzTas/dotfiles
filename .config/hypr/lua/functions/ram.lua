local M = {}

local file = require("functions.file")
local utils = require("functions.utils")

local get_ram_kb = utils.memoize(function()
    local meminfo = file.read("/proc/meminfo")
    if not meminfo then
        return 0
    end

    local kb = tonumber(meminfo:match("MemTotal:%s*(%d+)"))
    return kb or 0
end)

function M.get_kb()
    return get_ram_kb()
end

function M.get_mb()
    return math.floor(get_ram_kb() / 1024)
end

function M.get_gb()
    return math.floor(get_ram_kb() / 1024 / 1024 + 0.5)
end

function M.has_above(gb)
    return M.get_gb() > gb
end

return M
