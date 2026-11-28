require("plugins.darkwindow")
require("plugins.dinamic-cursors")
require("plugins.hymission")
require("plugins.hypr-edgehover")

hl.on("config.reloaded", function()
    hl.exec_cmd("hyprpm reload")
end)
