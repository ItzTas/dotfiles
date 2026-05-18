local M = {}

function M.memoize(fn)
    local result
    local computed = false
    return function()
        if not computed then
            result = fn()
            computed = true
        end
        return result
    end
end

function M.run_cmd(cmd)
    local h = io.popen(cmd)
    if not h then
        return nil
    end

    local out = h:read("*a")
    h:close()

    return (out and out ~= "") and out or nil
end

---@param cmd string
function M.run_async_cmd(cmd)
    hl.exec_cmd("bash -c '" .. cmd:gsub("'", "'\\''") .. "'")
end

---@param fn function
---@param timeout integer|nil
function M.defer(fn, timeout)
    hl.timer(fn, { timeout = timeout or 0, type = "oneshot" })
end

return M
