hl.config({
    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            new_optimizations  = true,
            ignore_opacity     = true,
            noise              = 0.02,
            contrast           = 0.9,
            brightness         = 0.85,
            vibrancy           = 0.25,
            vibrancy_darkness  = 0.15,
            popups             = true,
            popups_ignorealpha = 0.95,
        },

        shadow = {
            enabled      = true,
            range        = 65,
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
