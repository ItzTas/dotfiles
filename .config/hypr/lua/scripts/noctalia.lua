local utils = require("functions.utils")

local SETTINGS = "$HOME/.config/noctalia/settings.json"
local SHELL_CMD = "qs -c noctalia-shell"

-- Noctalia (quickshell) asks the compositor to blur behind the bar/panels through
-- `ext-background-effect-v1`. Hyprland's `shouldBlur()` short-circuits on that request
-- (`if (surface->m_hasBackgroundEffect) return !surface->m_blurRegion.empty()`), so the
-- blur can't be taken back with a layer rule, an exec rule (`no_blur`) or anything else
-- config-side short of killing `decoration:blur:enabled` globally. The only lever is
-- noctalia's own `general.enableBlurBehind`, and it has to be off *before* it starts.
local DISABLE_BLUR = string.format(
    'if [ -f %s ] && ! jq -e ".general.enableBlurBehind == false" %s >/dev/null 2>&1; then '
        .. 'tmp=$(mktemp) && jq ".general.enableBlurBehind = false" %s > "$tmp" && mv "$tmp" %s; fi',
    SETTINGS,
    SETTINGS,
    SETTINGS,
    SETTINGS
)

local M = {}

---Shell one-liner: strip the blur flag, then launch the shell.
M.start_cmd = DISABLE_BLUR .. "; " .. SHELL_CMD

function M.start()
    utils.run_async_cmd(M.start_cmd)
end

---Kill it if running, otherwise start it (blur-free).
function M.toggle()
    utils.run_async_cmd("killall qs || { " .. M.start_cmd .. "; }")
end

return M
