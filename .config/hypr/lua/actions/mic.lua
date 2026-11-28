local shell = require("lib.shell")

local M = {}

function M.toggle_mute()
    shell.run("mic/toggle_mute")
end

return M
