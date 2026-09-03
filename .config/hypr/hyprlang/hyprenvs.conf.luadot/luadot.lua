local machine = require("utils.machine")
local sections = require("utils.sections")

return sections.concat({
	{ when = true, file = "00-session.conf" },
	{ when = machine.gpu() == "nvidia", file = "10-nvidia.conf" },
	{ when = true, file = "20-system.conf" },
})
