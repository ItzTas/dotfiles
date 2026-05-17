local M = {}
local file = require("functions.file")
local utils = require("functions.utils")

local function parse_vendor(text)
    if not text or text == "" then
        return nil
    end

    local lower = text:lower()

    if lower:find("nvidia") then
        return "nvidia"
    end
    if lower:find("amd") or lower:find("radeon") or lower:find("advanced micro devices") then
        return "amd"
    end
    if lower:find("intel") then
        return "intel"
    end

    return nil
end

local function detect_via_hyprctl()
    return parse_vendor(utils.run_cmd("hyprctl systeminfo 2>/dev/null"))
end

local function detect_via_proc_nvidia()
    if file.exists("/proc/driver/nvidia/version") then
        return "nvidia"
    end
    return nil
end

local function detect_via_lspci()
    return parse_vendor(utils.run_cmd("lspci -nn 2>/dev/null | grep -iE 'vga|3d|display' 2>/dev/null"))
end

local function detect_via_sysfs()
    local pci_vendors = {
        ["0x10de"] = "nvidia",
        ["0x1002"] = "amd",
        ["0x8086"] = "intel",
    }

    local h = io.popen("ls -d /sys/class/drm/card*/device/vendor 2>/dev/null")
    if not h then
        return nil
    end

    local paths = h:read("*a")
    h:close()

    for path in paths:gmatch("[^\n]+") do
        local content = file.read(path)
        if content then
            local trimmed = content:match("^%s*(.-)%s*$")
            for id, vendor in pairs(pci_vendors) do
                if trimmed == id then
                    return vendor
                end
            end
        end
    end

    return nil
end

local function detect_via_glxinfo()
    return parse_vendor(utils.run_cmd("glxinfo 2>/dev/null | grep -i 'opengl vendor' 2>/dev/null"))
end

local detection_chain = {
    detect_via_hyprctl,
    detect_via_proc_nvidia,
    detect_via_lspci,
    detect_via_sysfs,
    detect_via_glxinfo,
}

local detect_vendor = utils.memoize(function()
    for _, detect_fn in ipairs(detection_chain) do
        local vendor = detect_fn()
        if vendor then
            return vendor
        end
    end
    return "unknown"
end)

function M.is_nvidia()
    return detect_vendor() == "nvidia"
end

function M.is_amd()
    return detect_vendor() == "amd"
end

function M.is_intel()
    return detect_vendor() == "intel"
end

function M.get_vendor()
    return detect_vendor()
end

return M
