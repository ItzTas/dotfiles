local gpu = require("lua.functions.gpu")

hl.on("hyprland.start", function()
    -- Cache cleanup
    hl.exec_cmd("paru -Sc --noconfirm")
    hl.exec_cmd("rm -rf ~/.cache/electron/*")
    hl.exec_cmd("rm -rf ~/Desktop/*")
    hl.exec_cmd("rm -rf ~/.cache/spotify/*")
    hl.exec_cmd("rm -rf ~/.config/Ferdium/Partitions/*/Cache/*")
    hl.exec_cmd("rm -rf ~/.config/Ferdium/Partitions/*/GPUCache/*")
    hl.exec_cmd("rm ~/steam-*.log")

    -- Core services
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd $HYPRLAND_INSTANCE_SIGNATURE $WAYLAND_DISPLAY $XDG_CURRENT_DESKTOP"
    )
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")
    hl.exec_cmd("hyprpaper")

    -- Desktop services
    hl.exec_cmd("gnome-keyring-daemon --start --daemonize --components=pkcs11,secrets,ssh")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd('bash ~/.config/waybar/lauch_waybar.sh "2"')
    hl.exec_cmd("swaync")

    -- Gitify
    hl.exec_cmd("sleep 11; gitify --password-store=gnome-libsecret")

    -- Clipboard
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("clipse -listen")

    -- Updates
    hl.exec_cmd("sleep 10; arch-update --tray")
    hl.exec_cmd("sleep 10; systemctl --user start arch-update.timer")

    -- Audio
    hl.exec_cmd("systemctl --user start pipewire")
    hl.exec_cmd("systemctl --user start pipewire-pulse")
    hl.exec_cmd("systemctl --user start wireplumber")

    -- Telemetry off
    hl.exec_cmd("go telemetry off")
    hl.exec_cmd("mkdir -p ~/.winboat; ln -s /dev/null ~/.winboat/appUsage.json")
    hl.exec_cmd("yarn next telemetry disable")

    -- System utilities
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("chmod +x ~/.config/hypr/hyprlock/bh/lockscripts.sh")
    hl.exec_cmd("yadm alt")

    -- Display/Graphics
    hl.exec_cmd("nvibrant 0 0 0 0 500")

    -- Gaming & extras
    hl.exec_cmd("systemctl --user start gamemoded")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("sleep 30 && protonvpn-app --start-minimized")

    -- Alarm
    hl.exec_cmd("alarm-clock-applet --hidden")
end)

--------- later
hl.exec_cmd("hyprpm reload")
hl.exec_cmd("eww --config ~/.config/eww/binaryharbinger daemon")
