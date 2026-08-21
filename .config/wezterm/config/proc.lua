local M = {}

-- Inside a multiplexer the foreground process of the wezterm pane is always the
-- multiplexer itself, so the program the user actually launched can only be
-- learned from the OSC 2 title it reports (tmux needs `set-titles on`).
local multiplexers = { tmux = true, screen = true, zellij = true }

---Name of whatever is running in the pane: "nvim", "btop", "bash", ...
---@param process string|nil absolute path of the foreground process
---@param title string|nil pane title, as set by OSC 2
---@return string
function M.name(process, title)
  local proc = process and process:match '([^/]+)$'
  if not proc or multiplexers[proc] then
    return title or proc or ''
  end
  return proc
end

return M
