local gpu = require("functions.gpu")
local ram = require("functions.ram")

local exec = hl.exec_cmd
local on = hl.on

local function cleanup()
	exec("rm -rf ~/.cache/electron/*")
	exec("rm -rf ~/Desktop/*")
	exec("rm -rf ~/.cache/spotify/*")
	exec("rm -rf ~/.config/Ferdium/Partitions/*/Cache/*")
	exec("rm -rf ~/.config/Ferdium/Partitions/*/GPUCache/*")
	exec("rm -rf ~/.cache/thumbnails/*")
	exec("rm ~/steam-*.log")
end

on("hyprland.start", function()
	cleanup()
	exec("paru -Sc --noconfirm")

	-- Core services
	exec(
		"dbus-update-activation-environment --systemd $HYPRLAND_INSTANCE_SIGNATURE $WAYLAND_DISPLAY $XDG_CURRENT_DESKTOP"
	)
	exec("hypridle")
	exec("hyprctl setcursor Bibata-Modern-Classic 24")
	exec("hyprpaper")

	-- Desktop services
	exec("gnome-keyring-daemon --start --daemonize --components=pkcs11,secrets,ssh")
	exec("systemctl --user start xdg-desktop-portal-hyprland")
	exec("qs -c noctalia-shell")

	-- Gitify
	exec("sleep 11; gitify --password-store=gnome-libsecret")

	-- Clipboard
	exec("wl-clip-persist --clipboard regular")
	exec("clipse -listen")

	-- Updates
	exec("sleep 10; arch-update --tray")
	exec("sleep 10; systemctl --user start arch-update.timer")

	-- Audio
	exec("systemctl --user start pipewire")
	exec("systemctl --user start pipewire-pulse")
	exec("systemctl --user start wireplumber")

	-- Telemetry off
	exec("go telemetry off")
	exec("mkdir -p ~/.winboat; ln -s /dev/null ~/.winboat/appUsage.json")
	exec("yarn next telemetry disable")

	-- System utilities
	-- exec("swayosd-server")
	exec("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	if gpu.is_nvidia() then
		exec("nvibrant 0 0 0 0 500")
	end

	if ram.has_above(8) then
		exec("sleep 30 && protonvpn-app --start-minimized")
		exec("systemctl --user start gamemoded")
		exec("easyeffects --gapplication-service")
	end
end)

on("hyprland.shutdown", function()
	cleanup()
	exec("yadm alt")
end)
