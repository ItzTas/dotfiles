local device = require("hw.form_factor")
local utils = require("lib.utils")

local monitor = hl.monitor

---@param output string
---@param first integer
---@param last integer
local function assign_workspaces(output, first, last)
    for i = first, last do
        hl.workspace_rule({
            workspace = tostring(i),
            monitor = output,
            default = true,
        })
    end
end

local monitor_defaults = utils.with_defaults({
    mode = "preferred",
    scale = 1,
    bitdepth = 10,
    cm = "srgb",
    supports_hdr = 1,
    sdrbrightness = 1,
    sdr_min_luminance = 0.005,
    sdr_max_luminance = 90,
}, "HL.MonitorSpec")

monitor(
    monitor_defaults({ output = "HDMI-A-1", position = "auto-left", sdrsaturation = 1.4 })
)

if device.is_laptop() then
    monitor(monitor_defaults({ output = "eDP-1", position = "auto-right", sdrsaturation = 1.15 }))

    assign_workspaces("HDMI-A-1", 1, 10)
    assign_workspaces("eDP-1", 11, 20)

    return
end

monitor(monitor_defaults({
    output = "DP-2",
    position = "auto-right",
    sdrsaturation = 1.15,
    -- vrr = 1,
    -- min_luminance = 0.005,
    -- max_luminance = 1000,
    -- max_avg_luminance = 600,
}))

assign_workspaces("DP-2", 1, 10)
assign_workspaces("HDMI-A-1", 11, 20)
