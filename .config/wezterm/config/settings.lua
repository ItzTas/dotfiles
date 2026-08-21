local wezterm = require 'wezterm'
local proc = require 'config.proc'

local M = {}

function M.apply(config)
  config.window_close_confirmation = 'NeverPrompt'
  config.default_prog = { 'env', '-u', 'TMUX', '-u', 'TMUX_PANE', 'bash' }

  config.audible_bell = 'Disabled'
  config.visual_bell = {
    fade_in_duration_ms = 0,
    fade_out_duration_ms = 0,
  }

  config.font = wezterm.font 'JetBrainsMonoNL Nerd Font'
  config.font_size = 16.0

  config.color_scheme_dirs = { wezterm.config_dir .. '/colors' }
  config.color_scheme = 'Noctalia'
  config.window_background_opacity = 0.4

  config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  }

  config.default_cursor_style = 'SteadyBlock'
  config.cursor_blink_rate = 0
  config.force_reverse_video_cursor = false

  -- tmux owns tabs and splits, wezterm is just the surface; config/statusbar.lua
  -- turns the tab bar row back on, using it as the container's top edge
  config.enable_tab_bar = false

  wezterm.on('format-window-title', function(tab)
    local pane = tab.active_pane
    return proc.name(pane.foreground_process_name, pane.title)
  end)
end

return M
