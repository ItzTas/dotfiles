local machine = require("utils.machine")
local sections = require("utils.sections")

local ram_gb = machine.ram_gb()

return sections.concat({
	{ when = true, file = "00-base.conf" },
	{ when = ram_gb > 8, file = "10-ram-8.conf" },
	{ when = ram_gb > 12, file = "20-ram-12.conf" },
	{ when = ram_gb > 16, file = "30-ram-16.conf" },
})
