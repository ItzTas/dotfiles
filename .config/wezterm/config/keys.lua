local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}

function M.apply(config)
  config.disable_default_key_bindings = true

  config.keys = {
    { key = '+', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
    { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },
    { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
    { key = 'Backspace', mods = 'CTRL', action = act.SendString '\x17' },
    { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
    { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
    { key = 'R', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
  }
end

return M
