local device = require("functions.device")

local monitor = hl.monitor
local rule = hl.workspace_rule

if device.is_laptop() then
    monitor({
        output = "eDP-1",
        mode = "preferred",
        position = "auto-right",
        scale = 1,

        bitdepth = 10,
        --
        -- cm = "hdr",
        -- supports_hdr = 1,
        --
        -- sdrbrightness = 1,
        -- sdrsaturation = 1.45,
        --
        -- sdr_min_luminance = 0.005,
        -- sdr_max_luminance = 90,
    })

    monitor({
        output = "HDMI-A-1",
        mode = "preferred",
        position = "auto-left",
        scale = 1,

        bitdepth = 10,

        cm = "hdr",
        supports_hdr = 1,

        sdrbrightness = 1,
        sdrsaturation = 1.4,

        sdr_min_luminance = 0.005,
        sdr_max_luminance = 90,
    })

    for i = 1, 10 do
        rule({
            workspace = tostring(i),
            monitor = "HDMI-A-1",
            default = true,
        })
    end

    for i = 11, 20 do
        rule({
            workspace = tostring(i),
            monitor = "eDP-1",
            default = true,
        })
    end
else
    monitor({
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,

        -- vrr = 1,
        bitdepth = 10,

        cm = "edid",
        supports_hdr = 1,

        sdrbrightness = 1,
        sdrsaturation = 1.1,

        sdr_min_luminance = 0.005,
        sdr_max_luminance = 90,

        -- min_luminance = 0.005,
        -- max_luminance = 1000,
        -- max_avg_luminance = 600,
    })
end
