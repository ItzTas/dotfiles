local gpu = require("functions.gpu")

local home = os.getenv("HOME")

local env = hl.env
local on = hl.on

on("hyprland.start", function()
    -- cursor
    env("XCURSOR_SIZE", "24")
    env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
    env("XCURSOR_THEME", "Bibata-Modern-Classic")
    env("HYPRCURSOR_SIZE", "24")

    -- hyprland envs
    env("XDG_SESSION_TYPE", "wayland")
    env("XDG_CURRENT_DESKTOP", "Hyprland")
    env("XDG_SESSION_DESKTOP", "Hyprland")

    if gpu.is_nvidia() then
        env("GBM_BACKEND", "nvidia-drm")
        env("DXVK_FILTER_DEVICE_NAME", "NVIDIA GeForce RTX 4060")
        env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
        env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

        -- nvidia hardware VA-API hardware video acceleration
        env("LIBVA_DRIVER_NAME", "nvidia")
        env("NVD_BACKEND", "direct")
    end

    -- proton
    env("PROTON_ENABLE_WAYLAND", "1")
    env("PROTON_ENABLE_HDR", "1")

    -- system theme
    env("QT_QPA_PLATFORMTHEME", "qt6ct")
    env("GTK_THEME", "catppuccin-mocha-lavender-standard+default")

    -- zsh home
    env("ZDOTDIR", home .. "/.config/zsh")
end)
