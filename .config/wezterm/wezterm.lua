local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- confirm_os_window_close 0
config.window_close_confirmation = 'NeverPrompt'

-- shell bash
-- env -u: wezterm inherits $TMUX when launched from inside a tmux pane, which
-- makes ~/.config/bash/config/binds skip the Ctrl+F / Ctrl+G binds.
config.default_prog = { 'env', '-u', 'TMUX', '-u', 'TMUX_PANE', 'bash' }

-- enable_audio_bell no / window_alert_on_bell no
config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 0,
  fade_out_duration_ms = 0,
}

-- window_padding_width 10 / window_margin_width 0
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- font_family JetBrainsMonoNL Nerd Font / font_size 16.0
config.font = wezterm.font 'JetBrainsMonoNL Nerd Font'
config.font_size = 16.0

-- include themes/noctalia.conf  (Noctalia writes colors/Noctalia.toml itself)
config.color_scheme_dirs = { wezterm.config_dir .. '/colors' }
config.color_scheme = 'Noctalia'

-- background_opacity 0.4
config.window_background_opacity = 0.4

-- cursor_shape block / cursor_blink_interval 0
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0
config.force_reverse_video_cursor = false

-- single window only: tmux owns tabs/splits, wezterm is just the surface
config.enable_tab_bar = false
-- the default bindings include SpawnTab, SpawnWindow and the split actions;
-- drop them all and re-declare only what is wanted below
config.disable_default_key_bindings = true

config.keys = {
  -- ctrl+plus zoom_in
  { key = '+', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  -- ctrl+minus zoom_out
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  -- ctrl+0 change_font_size all 0
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  -- f11 toggle_fullscreen
  { key = 'F11', mods = 'NONE', action = act.ToggleFullScreen },
  -- ctrl+backspace send_text all \x17
  { key = 'Backspace', mods = 'CTRL', action = act.SendString '\x17' },
  -- clipboard, kept from the defaults
  { key = 'C', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
  { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },
  { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
  -- config reload
  { key = 'R', mods = 'CTRL|SHIFT', action = act.ReloadConfiguration },
}

return config
