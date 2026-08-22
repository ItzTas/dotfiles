function upgrady
    argparse -X 0 h/help -- $argv
    or return 1

    if set -q _flag_help
        printf '%s\n' "Usage: "(status current-function) \
            "  updates AUR, flatpak, freshclam, hyprpm, snap and yadm, then prunes orphans"
        return 0
    end

    if command -q arch-update
        nohup arch-update --check >/dev/null 2>&1 &
        disown
    end

    set -l aur_helper ""
    if command -q paru
        set aur_helper paru
    else if command -q yay
        set aur_helper yay
    end

    if test -n "$aur_helper"
        $aur_helper -Syu --devel
        $aur_helper -Fy
    else
        echo "No AUR helper found (paru or yay)."
    end

    pacclean

    if command -q flatpak
        flatpak update
        flatpak uninstall --unused
    end

    if command -q freshclam
        sudo freshclam
    end

    if command -q hyprpm
        hyprpm update
    end

    if command -q snap
        sudo snap refresh
    end

    if command -q yadm
        yadm submodule update --init --remote --merge
    end

    if command -q yadm_update
        yadm_update
    end

    if command -q arch-update
        nohup arch-update --check >/dev/null 2>&1 &
        disown
    end
end
