function windows -d "Reboot straight into Windows once (systemd-boot one-shot entry)"
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  reboots into the Windows Boot Manager on the next boot only" \
            "  on Hyprland with hyprshutdown, closes the session gracefully first (same script as Noctalia)"
        return 0
    end

    set -l entry --boot-loader-entry=auto-windows
    set -l session_power ~/.config/noctalia/scripts/session-power.sh

    if not set -q HYPRLAND_INSTANCE_SIGNATURE; or not command -q hyprshutdown; or not test -x $session_power
        systemctl reboot $entry
        return
    end

    setsid -f $session_power reboot $entry
end
