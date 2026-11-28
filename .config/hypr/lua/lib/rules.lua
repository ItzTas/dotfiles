local utils = require("lib.utils")

local M = {}

---@alias RuleMatch table<string, string|number|boolean>
---@alias RuleEffects table<string, string|number|boolean>

---@param patterns string[]
---@return string
function M.any(patterns)
    return table.concat(patterns, "|")
end

---@param patterns string[]
---@return string
function M.except(patterns)
    return "negative:" .. M.any(patterns)
end

---@param pattern string
---@return string
function M.icase(pattern)
    return "(?i:" .. pattern .. ")"
end

---@param text string
---@param chars? string
---@return string
function M.literal(text, chars)
    local class = (chars or "^$().[]*+-?{}|\\"):gsub("%P", ""):gsub("%p", "%%%0")
    if class == "" then
        return text
    end
    return (text:gsub("[" .. class .. "]", "\\%0"))
end

---@param prefix string
---@param matches table<string, RuleMatch>
---@param effects RuleEffects
function M.each(prefix, matches, effects)
    local with_effects = utils.with_defaults(effects, "HL.WindowRuleSpec")
    for key, match in pairs(matches) do
        hl.window_rule(with_effects({ name = prefix .. "-" .. key, match = match }))
    end
end

---@param window_rule HL.WindowRule
---@param class string
---@param timeout integer
function M.enable_after_open(window_rule, class, timeout)
    if #hl.get_windows({ class = class }) > 0 then
        return
    end

    window_rule:set_enabled(false)

    hl.on("window.open", function(window)
        if window.class ~= class then
            return
        end
        utils.defer(function()
            window_rule:set_enabled(true)
        end, timeout)
    end)
end

return M
