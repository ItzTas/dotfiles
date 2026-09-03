local machine = require("utils.machine")

return ld.alt.file(machine.is_laptop() and "laptop.conf" or "desktop.conf")
