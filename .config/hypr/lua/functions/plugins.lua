local M = {}

---@param name string
---@return any|nil
function M.ensure_plugin(name)
    return hl.plugin[name] or nil
end

return M
