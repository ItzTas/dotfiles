local rules = require("lib.rules")

local any, icase, literal = rules.any, rules.icase, rules.literal

local rule = hl.window_rule

rules.each("float", {
    dialogs = {
        class = any({
            "confirm",
            "dialog",
            "error",
            "splash",
            "notification",
            "download",
            "file_progress",
        }),
    },
    ["file-managers"] = {
        class = any({
            icase("nemo"),
            "nautilus",
            "org.gnome.Nautilus",
            "dolphin",
            "thunar",
            "Pcmanfm",
        }),
    },
    ["image-viewers"] = {
        class = any({
            "org.kde.gwenview",
            "org.gnome.gThumb",
            "imv",
            "viewnior",
        }),
    },
    apps = {
        class = any({
            "Lxappearance",
            "ncmpcpp",
            "Rofi",
            "pavucontrol-qt",
            "gucharmap",
            "gnome-font",
            "org.gnome.Settings",
            "file-roller",
            "obs",
            "wdisplays",
            "keepassxc",
            "imFile",
            "clipse-gui",
            "confirmreset",
            "hyprnav",
            icase(literal("GameConqueror.py")),
            "screenshot-gui",
            icase("gitk"),
            "GitAhead",
            "zoom",
            "xdg-desktop-portal-gtk",
        }),
    },
    titles = {
        title = any({
            "Media viewer",
            "Transmission",
            "Volume Control",
            "Picture-in-Picture",
            "Winetricks.*",
            literal("Steam Achievement Notifier (V1.9): Notification"),
        }),
    },
    whatsapp = {
        class = "electron",
        title = literal("blob:https://web.whatsapp.com/") .. ".*",
    },
    filelight = {
        class = literal("org.kde.filelight"),
        title = "Filelight",
    },
    ["flameshot-save"] = {
        class = "flameshot",
        title = icase("save screenshot"),
    },
    meld = {
        class = "org.gnome.Meld",
        title = "Meld",
    },
}, { float = true })

rules.each("fullscreen", {
    players = { class = any({ "mpv", "vlc" }) },
    zathura = { class = any({ "zathura", "org.pwmt.zathura" }) },
    menus = { title = any({ "hyprpwmenu", "wlogout" }) },
}, { fullscreen = true })

rules.each("game", {
    steam = { class = "steam_app_.*" },
    wonderlands = { class = literal("wonderlands.exe") },
    rimworld = { class = "RimWorldLinux" },
    ["until-then"] = { class = "Until Then" },
    ["dome-keeper"] = {
        class = "Dome Keeper",
        title = "Dome Keeper",
    },
}, { fullscreen = true, immediate = true })

rule({
    name = "game-persona-5-royal",
    match = {
        class = "steam_app_.*",
        title = "Persona 5 Royal",
    },
    workspace = 4,
    focus_on_activate = false,
})

---@param title string
---@return string
local function zen(title)
    return icase(literal(title .. " — Zen Browser"))
end

rules.each("private", {
    bitwarden = { class = icase("bitwarden") },
    ["proton-pass"] = {
        class = "Proton Pass",
        title = "Proton Pass",
    },
    ["proton-authenticator"] = {
        class = "proton-authenticator",
        title = "Proton Authenticator",
    },
    binance = {
        class = "Binance",
        title = "Binance Desktop",
    },
    exodus = {
        class = icase("exodus"),
        title = icase("exodus [0-9]+\\.[0-9]+\\.[0-9]+"),
    },
    ["steam-pagseguro"] = {
        class = icase("steam"),
        title = icase("pagseguro"),
    },
    ["steam-apm"] = {
        class = icase("steam"),
        title = "APM Adapter",
    },
    ["zen-bitwarden"] = {
        class = "zen",
        title = zen("Extension: (Bitwarden Password Manager) - Bitwarden"),
    },
    ["zen-amazon"] = {
        class = "zen",
        title = zen("Faça seu pedido — finalização da compra na Amazon"),
    },
    ["zen-inter"] = {
        class = "zen",
        title = zen("Internet Banking Inter"),
    },
    ["zen-proton-wallet"] = {
        class = "zen",
        title = zen("Proton Wallet"),
    },
}, { no_screen_share = true })

rule({
    name = "steam-friends",
    match = {
        class = icase("steam"),
        title = any({ "Lista de amigos", icase("friends list") }),
    },
    float = true,
    opacity = "1.0 0.5 override",
    no_blur = true,
})

rule({
    name = "steam-main",
    match = {
        class = icase("steam"),
        title = icase("steam"),
    },
    opacity = "1.0 0.95 override",
    no_blur = true,
})

rule({
    name = "steam-empty",
    match = {
        class = icase("steam"),
        title = "^$",
    },
    opacity = "1.0 0.8 override",
})

rule({
    name = "nemo",
    match = { class = icase("nemo") },
    opacity = "1.0 0.4 override",
    no_blur = true,
    size = "(monitor_w*0.4) (monitor_h*0.60)",
    center = true,
})

rule({
    name = "nemo-screenshots",
    match = {
        class = icase("nemo"),
        title = "screenshots",
    },
    opacity = "1.0 0.3 override",
})

rule({
    name = "file-roller",
    match = { class = icase(literal("org.gnome.FileRoller")) },
    float = true,
    opacity = "1.0 0.4 override",
})

rule({
    name = "zathura-print",
    match = {
        class = "org.pwmt.zathura",
        title = icase("print"),
    },
    float = true,
    opacity = "1 0.6",
    no_blur = true,
    size = "800 600",
    center = true,
})

rule({
    name = "alarm-clock",
    match = { class = "alarm-clock-applet" },
    float = true,
    size = "900 700",
    center = true,
})

rule({
    name = "vesktop",
    match = { class = "vesktop" },
    opacity = "0.95 0.65",
    no_blur = true,
    focus_on_activate = true,
})

rule({
    name = "spotify",
    match = { class = icase("spotify") },
    opacity = "0.97 0.8",
    no_blur = true,
    workspace = 9,
})

rule({
    name = "no-blur",
    match = {
        class = any({
            "com.mitchellh.ghostty",
            "kitty",
            "org.wezfurlong.wezterm",
            "kando",
        }),
    },
    no_blur = true,
})

rule({
    name = "gitahead",
    match = { class = "GitAhead" },
    size = "1300 800",
    center = true,
})

rule({
    name = "gthumb",
    match = { class = "org.gnome.gThumb" },
    size = "1300 800",
})

rule({
    name = "volume-control",
    match = { title = "Volume Control" },
    size = "800 600",
    move = "(monitor_w*0.75) (monitor_h*0.44)",
})

rule({
    name = "gitify",
    match = {
        class = "gitify",
        title = icase("gitify"),
    },
    move = "(monitor_w*0.705) (monitor_h*0.045)",
    no_initial_focus = true,
})

rule({
    name = "kando-menu",
    match = {
        title = icase("kando menu"),
        float = true,
    },
    pin = true,
})

rule({
    name = "parsec",
    match = {
        class = "parsecd",
        title = icase("parsec"),
        fullscreen = true,
    },
    immediate = true,
})

rules.each("activate", {
    zen = { class = "zen" },
    ferdium = {
        class = icase("ferdium"),
        title = icase("ferdium.*"),
    },
    hydralauncher = {
        class = "hydralauncher",
        title = icase("hydra launcher"),
    },
}, { focus_on_activate = true })

local thunderbird = "org.mozilla.Thunderbird"

rules.enable_after_open(
    rule({
        name = "thunderbird",
        match = { class = literal(thunderbird) },
        focus_on_activate = true,
    }),
    thunderbird,
    15000
)

rule({
    name = "thunderbird-new-message",
    match = {
        class = literal(thunderbird),
        title = icase("(escrever|write):.*"),
    },
    workspace = 6,
})

rule({
    name = "empty-xwayland",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

rule({
    name = "floating",
    match = {
        class = ".*",
        float = true,
    },
    decorate = false,
})

rule({
    name = "hyprland-dialog",
    match = {
        class = "hyprland-dialog",
        title = "Application Not Responding",
        float = true,
    },
    move = "onscreen (monitor_w*0.95) (monitor_h*0.10)",
    no_initial_focus = true,
})
