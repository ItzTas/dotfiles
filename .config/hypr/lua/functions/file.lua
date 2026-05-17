local M = {}

function M.read(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local out = f:read("*a")
    f:close()
    return (out and out ~= "") and out or nil
end

function M.exists(path)
    local f = io.open(path, "r")
    if f then f:close() return true end
    return false
end

return M
