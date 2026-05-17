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

return M
