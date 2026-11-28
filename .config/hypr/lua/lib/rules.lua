local M = {}

---@param patterns string[]
---@return string
function M.any(patterns)
    return table.concat(patterns, "|")
end

---@param patterns string[]
---@return string
function M.except(patterns)
    return "negative:" .. M.any(patterns)
end

return M
