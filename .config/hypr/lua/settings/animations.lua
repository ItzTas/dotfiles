hl.config({
    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 1,    bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.4,  bezier = "default",  style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 6,    bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 5,    bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 1,    bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 0.50, bezier = "default" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 1.3,  bezier = "default",  style = "slide" })
