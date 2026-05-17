hl.config({
    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled          = true,
            size             = 10,
            passes           = 1,
            new_optimizations = true,
            contrast         = 1.0,
            brightness       = 1.0,
            popups_ignorealpha = 0.95,
        },

        shadow = {
            enabled      = true,
            range        = 65,
            offset       = "1 2",
            render_power = 2,
            scale        = 0.97,
            color        = "rgba(1E202966)",
        },
    },

    general = {
        col = {
            active_border   = { colors = {"rgba(B4BEFEFF)", "rgba(B5BFFFE6)"} },
            inactive_border = { colors = {"rgba(33334CDD)", "rgba(34354DDD)"} },
        },
    },
})
