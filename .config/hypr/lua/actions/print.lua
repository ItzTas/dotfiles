local shell = require("lib.shell")

local M = {}

function M.area()
	shell.run("print/area")
end

function M.screen()
	shell.run("print/screen")
end

function M.window()
	shell.run("print/window")
end

return M
