local gpu = require("functions.gpu")
local ram = require("functions.ram")
local noctalia = require("scripts.noctalia")

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

	-- Core services
	exec("dbus-update-activation-environment --systemd HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	exec("hypridle")
	exec("hyprctl setcursor Bibata-Modern-Classic 24")

	-- Desktop services
	exec("rm -f $XDG_RUNTIME_DIR/ssh-agent.socket; ssh-agent -a $XDG_RUNTIME_DIR/ssh-agent.socket")
	exec("gnome-keyring-daemon --start --daemonize --components=pkcs11,secrets")
	noctalia.start()

	-- Gitify
	-- exec("sleep 11; gitify --password-store=gnome-libsecret")

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

	-- Screen sharing
	exec(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && "
			.. "systemctl --user restart xdg-desktop-portal-hyprland.service"
	)

	-- System utilities
	-- exec("swayosd-server")
	exec("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Others
	exec("killall dunst; sleep 30 && killall dunst; sleep 120 && killall dunst ")

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
