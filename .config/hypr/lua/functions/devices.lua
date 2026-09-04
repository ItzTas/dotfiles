local utils = require("functions.utils")
local notify = require("envs.notify")

local M = {}

---@type table<string, boolean>
local states = {}

---@param device string|HL.DeviceSpec
---@return HL.DeviceSpec
local function to_spec(device)
    if type(device) == "string" then
        return { name = device }
    end

    local copy = {}
    for k, v in pairs(device) do
        copy[k] = v
    end
    return copy
end

---@class DeviceToggleOpts
---@field label? string
---@field icon? string

---@param device string|HL.DeviceSpec
---@param opts? DeviceToggleOpts
---@return boolean enabled
function M.toggle(device, opts)
    opts = opts or {}

    local spec = to_spec(device)
    local name = spec.name
    local enabled = states[name] == false

    states[name] = enabled
    spec.enabled = enabled
    hl.device(spec)

    utils.run_async_cmd(
        string.format(
            'notify-send -e -i "%s" -r %d "%s: %s"',
            opts.icon or "input-mouse",
            notify.REPLACE_ID,
            opts.label or name,
            enabled and "Enabled" or "Disabled"
        )
    )

    return enabled
end

return M
