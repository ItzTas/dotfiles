local M = {}

---@param name string
---@return any|nil
function M.ensure_plugin(name)
    return hl.plugin[name] or nil
end

---@param names? string[]
---@return boolean
function M.has_any_plugin(names)
    if not names then
        return next(hl.plugin) ~= nil
    end
    for _, name in ipairs(names) do
        if hl.plugin[name] then
            return true
        end
    end
    return false
end

return M
