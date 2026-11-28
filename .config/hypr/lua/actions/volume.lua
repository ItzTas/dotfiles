local shell = require("lib.shell")

local M = {}

---@param step integer e.g. 5 for +5%, -5 for -5%
function M.adjust(step)
    shell.run("volume/adjust", { args = { step } })
end

function M.toggle_mute()
    shell.run("volume/toggle_mute")
end

return M
