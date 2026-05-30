local plugins = require("functions.plugins")

if not plugins.has_any_plugin() then return end

require("plugins.darkwindow")
require("plugins.dinamic-cursors")
require("plugins.hyprexpo")
require("plugins.hymission")

hl.on("config.reloaded", function()
    hl.exec_cmd("hyprpm reload")
end)
