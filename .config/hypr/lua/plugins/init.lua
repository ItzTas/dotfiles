require("plugins.darkwindow")
require("plugins.dinamic-cursors")
require("plugins.hymission")
require("plugins.hypr-edgehover")

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpm reload")
end)
