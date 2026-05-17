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

return M
