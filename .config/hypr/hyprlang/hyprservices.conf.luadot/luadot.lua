local machine = require("utils.machine")
local sections = require("utils.sections")

local ram_gb, is_laptop = machine.ram_gb(), machine.is_laptop()

return sections.concat({
	{ when = true, file = "00-base.conf" },
	{ when = machine.gpu() == "nvidia", file = "10-nvidia.conf" },
	{ when = ram_gb > 8, file = "20-ram-8.conf" },
	{ when = ram_gb > 8 and not is_laptop, file = "30-desktop.conf" },
})
