-- cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")

-- hyprland envs
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("DXVK_FILTER_DEVICE_NAME", "NVIDIA GeForce RTX 4060")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- nvidia hardware VA-API hardware video acceleration
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- proton
hl.env("PROTON_ENABLE_WAYLAND", "1")
hl.env("PROTON_ENABLE_HDR", "1")

-- system theme
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GTK_THEME", "catppuccin-mocha-lavender-standard+default")

-- zsh home
hl.env("ZDOTDIR", "$HOME/.config/zsh")
