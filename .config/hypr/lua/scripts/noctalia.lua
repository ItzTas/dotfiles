local utils = require("functions.utils")

-- Noctalia v5: native binary `noctalia`, IPC via `noctalia msg <command>`.
-- Config lives in ~/.config/noctalia/*.toml (hot-reloaded), so nothing has to be
-- patched before launch anymore — the v4 `general.enableBlurBehind` jq hack is gone
-- (v5 no longer forces blur through `ext-background-effect-v1`).
local SHELL_CMD = "noctalia"
local IPC = "noctalia msg"

local M = {}

M.start_cmd = SHELL_CMD

---Build a `noctalia msg …` command line for a keybind.
---@param command string
---@return string
function M.msg(command)
    return IPC .. " " .. command
end

function M.start()
    utils.run_async_cmd(M.start_cmd)
end

---Kill it if running, otherwise start it.
function M.toggle()
    utils.run_async_cmd("pkill -x noctalia || { " .. M.start_cmd .. "; }")
end

return M
