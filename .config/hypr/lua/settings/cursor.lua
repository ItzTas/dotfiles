hl.config({
    cursor = {
        enable_hyprcursor  = true,
        hide_on_key_press  = true,
    },
})

hl.on("config.reloaded", function()
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
end)
