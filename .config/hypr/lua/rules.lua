hl.window_rule({
    name = "all-windows",
    match = { class = ".*" },
})

hl.window_rule({
    name = "empty-xwayland",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "mpv",
    match = { class = "mpv" },
    fullscreen = true,
})

hl.window_rule({
    name = "parsec",
    match = {
        class      = "parsecd",
        title      = "[Pp]arsec",
        fullscreen = true,
    },
    immediate = true,
})

hl.window_rule({
    name = "vlc",
    match = { class = "vlc" },
    fullscreen = true,
})

hl.window_rule({
    name = "hyprpwmenu",
    match = { class = "title:hyprpwmenu" },
    fullscreen = true,
})

hl.window_rule({
    name = "zathura",
    match = { class = "zathura" },
    fullscreen = true,
})

hl.window_rule({
    name = "zathura-org",
    match = { class = "org.pwmt.zathura" },
    fullscreen = true,
})

hl.window_rule({
    name = "wlogout",
    match = { class = "title:wlogout" },
    fullscreen = true,
})

hl.window_rule({
    name = "steam-games",
    match = { class = "(steam_app_)(.*)" },
    fullscreen = true,
    immediate  = true,
})

hl.window_rule({
    name = "wonderlands",
    match = { class = "wonderlands\\.exe" },
    fullscreen = true,
})

hl.window_rule({
    name = "rimworld",
    match = { class = "RimWorldLinux" },
    fullscreen = true,
})

hl.window_rule({
    name = "hyprnav",
    match = { class = "hyprnav" },
    float = true,
})

hl.window_rule({
    name = "gameconqueror",
    match = { class = "^([Gg]ame[Cc]onqueror.py)$" },
    float = true,
})

hl.window_rule({
    name = "screenshot-gui",
    match = { class = "^(screenshot-gui)$" },
    float = true,
})

hl.window_rule({
    name = "steam-friends-pt",
    match = {
        class = "[Ss]team",
        title = "^(Lista de amigos)$",
    },
    float   = true,
    opacity = "1.0 0.5 override",
    no_blur = true,
})

hl.window_rule({
    name = "steam-friends-en",
    match = {
        class = "^([Ss]team)$",
        title = "^([Ff]riends [Ll]ist)$",
    },
    float   = true,
    opacity = "1.0 0.5 override",
    no_blur = true,
})

hl.window_rule({
    name = "dialogs",
    match = { class = "confirm|dialog|error|splash|notification|download|file_progress" },
    float = true,
})

hl.window_rule({
    name = "file-managers",
    match = { class = "[Nn]emo|nautilus|org.gnome.Nautilus|dolphin|thunar|Pcmanfm" },
    float = true,
})

hl.window_rule({
    name = "thunderbird",
    match = { class = "^(org.mozilla.Thunderbird)$" },
    focus_on_activate = true,
})

hl.window_rule({
    name = "thunderbird-new-message",
    match = {
        class = "^(org.mozilla.Thunderbird)$",
        title = "(?i)^(escrever|write):(.*)",
    },
    workspace = 6,
})

hl.window_rule({
    name = "image-viewers",
    match = { class = "org.kde.gwenview|org.gnome.gThumb|imv|viewnior" },
    float = true,
})

hl.window_rule({
    name = "misc-apps",
    match = { class = "Lxappearance|ncmpcpp|Rofi|pavucontrol-qt|gucharmap|gnome-font|org.gnome.Settings|file-roller|obs|wdisplays|keepassxc|imFile|clipse-gui|confirmreset" },
    float = true,
})

hl.window_rule({
    name = "git-apps",
    match = { class = "[Gg]itk|GitAhead" },
    float = true,
})

hl.window_rule({
    name = "zoom",
    match = { class = "zoom" },
    float = true,
})

hl.window_rule({
    name = "xdg-portal-gtk-open",
    match = {
        class = "^xdg-desktop-portal-gtk$",
        title = "^Open Files$",
    },
    float = true,
})

hl.window_rule({
    name = "media-titles",
    match = { title = "^(Media viewer)$|^(Transmission)$|^(Volume Control)$|^(Picture-in-Picture)$|^(Winetricks)(.*)?$|^(Steam Achievement Notifier \\(V1\\.9\\): Notification)$" },
    float = true,
})

hl.window_rule({
    name = "file-roller",
    match = { class = "org.gnome.FileRoller" },
    float = true,
})

hl.window_rule({
    name = "whatsapp-electron",
    match = {
        class = "electron",
        title = "blob:https://web.whatsapp.com/(.*)",
    },
    float = true,
})

hl.window_rule({
    name = "xdg-portal",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
})

hl.window_rule({
    name = "filelight",
    match = {
        class = "org\\.kde\\.filelight",
        title = "Filelight",
    },
    float = true,
})

hl.window_rule({
    name = "flameshot-save",
    match = {
        class = "flameshot",
        title = "^([Ss]ave screenshot)$",
    },
    float = true,
})

hl.window_rule({
    name = "zathura-print",
    match = {
        class = "org.pwmt.zathura",
        title = "^([Pp]rint)$",
    },
    float   = true,
    opacity = "1 0.6",
    no_blur = true,
    size    = "800 600",
    center  = true,
})

hl.window_rule({
    name = "alarm-clock",
    match = { class = "^(alarm-clock-applet)$" },
    float  = true,
    size   = "900 700",
    center = true,
})

hl.window_rule({
    name = "meld",
    match = {
        class = "^(org.gnome.Meld)$",
        title = "^(Meld)$",
    },
    float = true,
})

hl.window_rule({
    name = "steam-main",
    match = {
        class = "^([Ss]team)$",
        title = "^([Ss]team)$",
    },
    opacity = "1.0 0.95 override",
    no_blur = true,
})

hl.window_rule({
    name = "steam-empty",
    match = {
        class = "^([Ss]team)$",
        title = "^()$",
    },
    opacity = "1.0 0.8 override",
})

hl.window_rule({
    name = "vesktop",
    match = { class = "vesktop" },
    opacity          = "0.93 0.65",
    no_blur          = true,
    focus_on_activate = true,
})

hl.window_rule({
    name = "spotify",
    match = { class = "[Ss]potify" },
    opacity          = "0.97 0.8",
    no_blur          = true,
    workspace        = 9,
    focus_on_activate = true,
})

hl.window_rule({
    name = "nemo",
    match = { class = "^([Nn]emo)$" },
    opacity = "1.0 0.4 override",
    no_blur = true,
    size    = "(monitor_w*0.4) (monitor_h*0.60)",
    center  = true,
})

hl.window_rule({
    name = "nemo-screenshots",
    match = {
        class = "^([Nn]emo)$",
        title = "^(screenshots)$",
    },
    opacity = "1.0 0.3 override",
})

hl.window_rule({
    name = "fileroller",
    match = { class = "^(org.gnome.[Ff]ile[Rr]oller)$" },
    opacity = "1.0 0.4 override",
})

hl.window_rule({
    name = "ghostty",
    match = { class = "^(com.mitchellh.ghostty)$" },
    no_blur = true,
})

hl.window_rule({
    name = "kitty",
    match = { class = "^(kitty)$" },
    no_blur = true,
})

hl.window_rule({
    name = "kando",
    match = { class = "^(kando)$" },
    no_blur = true,
})

hl.window_rule({
    name = "bitwarden",
    match = { class = "^([Bb]itwarden)$" },
    no_screen_share = true,
})

hl.window_rule({
    name = "steam-pagseguro",
    match = {
        class = "^([Ss]team)$",
        title = "^([Pp]ag[Ss]eguro)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "steam-apm",
    match = {
        class = "^([Ss]team)$",
        title = "^(APM Adapter)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "zen-bitwarden",
    match = {
        class = "^(zen)$",
        title = "^([Ee]xtension: \\([Bb]itwarden [Pp]assword [Mm]anager\\) - [Bb]itwarden — [Zz]en [Bb]rowser)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "zen-amazon",
    match = {
        class = "^(zen)$",
        title = "^(Faça seu pedido — finalização da compra na Amazon — [Zz]en [Bb]rowser)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "zen",
    match = { class = "^(zen)$" },
    focus_on_activate = true,
})

hl.window_rule({
    name = "zen-inter",
    match = {
        class = "^(zen)$",
        title = "^(Internet Banking Inter — [Zz]en [Bb]rowser)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "ferdium",
    match = {
        class = "^([Ff]erdium)$",
        title = "^([Ff]erdium)(.*)",
    },
    focus_on_activate = true,
})

hl.window_rule({
    name = "p3r",
    match = {
        title = "P3R(.*)",
        class = "steam_app_(.*)",
    },
    immediate = true,
})

hl.window_rule({
    name = "gitahead",
    match = { class = "GitAhead" },
    size   = "1300 800",
    center = true,
})

hl.window_rule({
    name = "gthumb",
    match = { class = "org.gnome.gThumb" },
    size = "1300 800",
})

hl.window_rule({
    name = "volume-control",
    match = { title = "^(Volume Control)$" },
    size = "800 600",
    move = "(monitor_w*0.75) (monitor_h*0.44)",
})

hl.window_rule({
    name = "floating",
    match = {
        class = "(.*)",
        float = true,
    },
    decorate = false,
})

hl.window_rule({
    name = "hyprland-dialog",
    match = {
        class = "hyprland-dialog",
        title = "Application Not Responding",
        float = true,
    },
    move             = "onscreen (monitor_w*0.95) (monitor_h*0.10)",
    no_initial_focus = true,
})

hl.window_rule({
    name = "gitify",
    match = {
        class = "^(gitify)$",
        title = "^([Gg]itify)$",
    },
    move             = "(monitor_w*0.705) (monitor_h*0.045)",
    no_initial_focus = true,
})

hl.window_rule({
    name = "kando-menu",
    match = {
        title = "[Kk]ando [Mm]enu",
        float = true,
    },
    pin = true,
})

hl.window_rule({
    name = "timeshift",
    match = { class = "(Timeshift-gtk)" },
})

hl.window_rule({
    name = "flameshot-config",
    match = {
        class = "^(flameshot)$",
        title = "Configuration",
    },
})

hl.window_rule({
    name = "persona-5-royal",
    match = {
        class = "steam_app_(.*)",
        title = "^(Persona 5 Royal)$",
    },
    workspace        = 4,
    focus_on_activate = false,
    fullscreen       = true,
})

hl.window_rule({
    name = "proton-authenticator",
    match = {
        class = "^(proton-authenticator)$",
        title = "^(Proton Authenticator)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "proton-wallet-zen",
    match = {
        class = "zen",
        title = "Proton Wallet — Zen Browser",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "proton-pass",
    match = {
        class = "^(Proton Pass)$",
        title = "^(Proton Pass)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "until-then",
    match = { class = "^(Until Then)$" },
    fullscreen = true,
})

hl.window_rule({
    name = "binance-desktop",
    match = {
        class = "^(Binance)$",
        title = "^(Binance Desktop)$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "exodus",
    match = {
        class = "[Ee]xodus",
        title = "^[Ee][Xx][Oo][Dd][Uu][Ss] [0-9]+\\.[0-9]+\\.[0-9]+$",
    },
    no_screen_share = true,
})

hl.window_rule({
    name = "hydralauncher",
    match = {
        class = "^(hydralauncher)$",
        title = "^([Hh]ydra [Ll]auncher)$",
    },
    focus_on_activate = true,
})

hl.window_rule({
    name = "dome-keeper",
    match = {
        class = "^(Dome Keeper)$",
        title = "^(Dome Keeper)$",
    },
    fullscreen = true,
})
