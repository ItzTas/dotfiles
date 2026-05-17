local M = {}

local file = require("functions.file")
local utils = require("functions.utils")

local laptop_indicators = {
    "/sys/class/power_supply/BAT0",
    "/sys/class/power_supply/BAT1",
    "/sys/class/power_supply/BATT",
    "/sys/class/power_supply/CMB0",
    "/sys/class/backlight/intel_backlight",
    "/sys/class/backlight/amdgpu_bl0",
    "/sys/class/backlight/nvidia_0",
    "/sys/class/backlight/acpi_video0",
}

local function detect_via_battery()
    for _, path in ipairs(laptop_indicators) do
        if file.exists(path) then
            return "laptop"
        end
    end
    return nil
end

local function detect_via_chassis()
    local content = file.read("/sys/class/dmi/id/chassis_type")
    if not content then
        return nil
    end

    local chassis = tonumber(content:match("^%s*(%d+)%s*$"))
    if not chassis then
        return nil
    end

    local laptop_types = {
        [8]  = true,
        [9]  = true,
        [10] = true,
        [14] = true,
        [31] = true,
        [32] = true,
    }

    if laptop_types[chassis] then
        return "laptop"
    end

    return "desktop"
end

local function detect_via_hostnamectl()
    local out = utils.run_cmd("hostnamectl 2>/dev/null | grep -i chassis 2>/dev/null")
    if not out then
        return nil
    end

    local chassis = out:lower()
    if chassis:find("laptop") or chassis:find("notebook") or chassis:find("convertible") or chassis:find("tablet") then
        return "laptop"
    end
    if chassis:find("desktop") or chassis:find("server") then
        return "desktop"
    end

    return nil
end

local detection_chain = {
    detect_via_chassis,
    detect_via_battery,
    detect_via_hostnamectl,
}

local detect_type = utils.memoize(function()
    for _, detect_fn in ipairs(detection_chain) do
        local dtype = detect_fn()
        if dtype then
            return dtype
        end
    end
    return "unknown"
end)

function M.is_laptop()
    return detect_type() == "laptop"
end

function M.is_desktop()
    return detect_type() == "desktop"
end

function M.get_type()
    return detect_type()
end

return M
