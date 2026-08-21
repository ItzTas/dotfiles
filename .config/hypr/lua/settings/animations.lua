hl.config({
    animations = {
        enabled = true,
    },
})

-- Curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

-- speed unit = 100ms (lower = faster)
hl.animation({ leaf = "global",        enabled = true, speed = 2,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 1,    bezier = "easeOutQuint" })
hl.animation({ leaf = "borderangle",   enabled = true, speed = 1,    bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 0.8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1.5,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 0.4,  bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 0.8,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "fade",          enabled = true, speed = 0.6,  bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 0.4,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 0.4,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeSwitch",    enabled = true, speed = 0.2,  bezier = "quick" })
hl.animation({ leaf = "fadeDim",       enabled = true, speed = 0.4,  bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 0.7,  bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 0.7,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 0.4,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.4,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.3,  bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 0.7,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 1.5,  bezier = "quick" })
hl.animation({ leaf = "fadeDpms",      enabled = true, speed = 2,    bezier = "almostLinear" })
hl.animation({ leaf = "monitorAdded",  enabled = true, speed = 2,    bezier = "easeOutQuint" })
