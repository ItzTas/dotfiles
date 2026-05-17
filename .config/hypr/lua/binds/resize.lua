hl.bind("$scndMod + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("L", hl.dsp.resizeactive("20 0"), { repeating = true })

    hl.bind("H", hl.dsp.resizeactive("-20 0"), { repeating = true })

    hl.bind("K", hl.dsp.resizeactive("0 -20"), { repeating = true })

    hl.bind("J", hl.dsp.resizeactive("0 20"), { repeating = true })

    hl.bind("$scndMod + R", hl.dsp.submap("reset"))
end)
