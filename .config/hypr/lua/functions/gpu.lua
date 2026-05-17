local M = {}

local function get_systeminfo()
    local h = io.popen("hyprctl systeminfo 2>/dev/null")

    if not h then
        return nil
    end

    local out = h:read("*a")
    h:close()

    if not out or out == "" then
        return nil
    end

    return out:lower()
end

function M.is_nvidia()
    local out = get_systeminfo()

    if not out then
        return false
    end

    return out:find("nvidia") ~= nil
end

function M.get_vendor()
    local out = get_systeminfo()

    if not out then
        return "unknown"
    end

    if out:find("nvidia") then
        return "nvidia"
    end
    if out:find("amd") or out:find("radeon") then
        return "amd"
    end
    if out:find("intel") then
        return "intel"
    end

    return "unknown"
end

return M
