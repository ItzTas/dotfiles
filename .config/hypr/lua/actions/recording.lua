local shell = require("lib.shell")

local M = {}

function M.toggle()
    shell.run("recording/toggle")
end

return M
