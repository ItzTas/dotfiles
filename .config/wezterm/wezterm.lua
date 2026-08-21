local wezterm = require("wezterm")

local config = wezterm.config_builder()

for _, module in ipairs({ "settings", "keys", "statusbar" }) do
	require("config." .. module).apply(config)
end

return config
