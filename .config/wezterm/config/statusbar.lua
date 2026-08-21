-- Single status row drawn as the top edge of a container, with whatever is
-- running in the pane as its title:
--
--   ╭─ nvim ──────────────────────────────────────╮
--
-- wezterm only has one status row (top or bottom) and draws nothing along the
-- sides or under the terminal area, so this is the top edge alone. A closed box
-- around the content is tmux's job (`pane-border-status top`).
local wezterm = require 'wezterm'
local proc = require 'config.proc'

local M = {}

local CORNER_LEFT = '╭─ '
local CORNER_RIGHT = '╮'
local LINE = '─'

---@param config table wezterm config builder
function M.apply(config)
  config.enable_tab_bar = true
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = false
  config.hide_tab_bar_if_only_one_tab = false
  config.show_new_tab_button_in_tab_bar = false
  config.tab_max_width = 1

  -- the row is the container's edge, so it gets no background of its own; the
  -- translucent window shows through it
  config.colors = config.colors or {}
  config.colors.tab_bar = { background = 'transparent' }

  -- tmux owns the tabs, so there is only ever one and it carries no title
  wezterm.on('format-tab-title', function()
    return ''
  end)

  wezterm.on('update-status', function(window, pane)
    local palette = window:effective_config().resolved_palette
    local border = palette.ansi[1]
    local title = palette.ansi[3]

    local name = proc.name(pane:get_foreground_process_name(), pane:get_title())
    -- the row honours window_padding, so it is exactly as wide as the terminal
    -- area and the edge lines up with the text it wraps
    local used = wezterm.column_width(CORNER_LEFT .. name .. ' ' .. CORNER_RIGHT)
    local fill = math.max(pane:get_dimensions().cols - used, 0)

    window:set_left_status(wezterm.format {
      { Foreground = { Color = border } },
      { Text = CORNER_LEFT },
      { Foreground = { Color = title } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = name },
      { Attribute = { Intensity = 'Normal' } },
      { Foreground = { Color = border } },
      { Text = ' ' .. LINE:rep(fill) .. CORNER_RIGHT },
    })
  end)
end

return M
