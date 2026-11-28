local shell = require("lib.shell")

local M = {}

---@param delta number positive to increase, negative to decrease
function M.adjust_brightness(delta)
	shell.run("ddc/brightness", { args = { delta } })
end

function M.light_up()
	M.adjust_brightness(10)
end

function M.light_down()
	M.adjust_brightness(-10)
end

return M
