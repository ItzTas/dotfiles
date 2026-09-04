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
---@field label? string  name shown in the notification (defaults to the device name)
---@field icon? string   notification icon (freedesktop icon name or path)

---Toggle a device on/off. Pass the device name, or a full spec to keep its
---other options applied on every toggle.
---@param device string|HL.DeviceSpec
---@param opts? DeviceToggleOpts
---@return boolean enabled  the new state
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

hl.device({
    name = "sony-interactive-entertainment-dualsense-wireless-controller-touchpad",
    enabled = false,

    middle_button_emulation = false,
    tap_to_click = false,
    natural_scroll = true,
    clickfinger_behavior = false,
})

hl.device({
    name = "dualsense-wireless-controller-touchpad",
    enabled = false,

    middle_button_emulation = false,
    tap_to_click = false,
    natural_scroll = true,
    clickfinger_behavior = false,
})

hl.device({
    name = "asue1200:00-04f3:3288-touchpad",
    -- sensitivity = 3,
})

hl.device({
    name = "-usb-optical-mouse",
    sensitivity = 0.5
})

hl.device({
    name = "telink-wireless-receiver-mouse",
    sensitivity = 0.6
})

hl.device({
    name = "pixart-usb-optical-mouse",
    sensitivity = 0.6
})

return M
