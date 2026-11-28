hl.device({
    name = "sony-interactive-entertainment-dualsense-wireless-controller-touchpad",
    enabled = false,

    middle_button_emulation = false,
    tap_to_click = false,
    natural_scroll = true,
    clickfinger_behavior = false,
})

hl.device({
    name = "dualsense-wireless-controller-touchpad",
    enabled = false,

    middle_button_emulation = false,
    tap_to_click = false,
    natural_scroll = true,
    clickfinger_behavior = false,
})

hl.device({
    name = "asue1200:00-04f3:3288-touchpad",
    -- sensitivity = 3,
})

hl.device({
    name = "-usb-optical-mouse",
    sensitivity = 0.5
})

hl.device({
    name = "telink-wireless-receiver-mouse",
    sensitivity = 0.6
})

hl.device({
    name = "pixart-usb-optical-mouse",
    sensitivity = 0.6
})

-- Matches Windows with "Enhance pointer precision" off and the Windows 11 Settings speed at 10 (of 1-20),
-- which is raw 1:1. The DPI lives in the mouse's onboard profile, so it's the same on both systems.
hl.device({
    name = "logitech-pro-2-mouse-1",
    accel_profile = "flat",
    sensitivity = 0,
})
