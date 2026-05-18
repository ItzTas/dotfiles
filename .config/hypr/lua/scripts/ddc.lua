local utils = require("functions.utils")

local M = {}

---@param delta number positive to increase, negative to decrease
function M.adjust_brightness(delta)
    utils.run_async_cmd(
        string.format(
            "current=$(ddcutil getvcp 10 | awk -F'= ' '/current value/ {gsub(/^[ \\t]+|[ \\t]+$/, \"\", $2); gsub(/,/, \"\", $2); print $2}' | awk '{print $1}');"
                .. " new=$((current + (%d)));"
                .. ' [ "$new" -gt 100 ] && new=100;'
                .. ' [ "$new" -lt 0 ] && new=0;'
                .. ' ddcutil setvcp 10 "$new"',
            delta
        )
    )
end

function M.light_up()
    M.adjust_brightness(10)
end

function M.light_down()
    M.adjust_brightness(-10)
end

return M
