local M = {}

---@param name string
---@return any|nil
function M.ensure_plugin(name)
    return hl.plugin[name] or nil
end

---@param name string
---@return boolean
function M.is_loaded(name)
    for _, plugin in ipairs(hl.get_loaded_plugins()) do
        if plugin.name == name then
            return true
        end
    end
    return false
end

return M
