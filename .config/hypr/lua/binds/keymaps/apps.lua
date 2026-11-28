local mods = require("const.mods")
local apps = require("const.apps")
local binds = require("lib.binds")
local shell = require("lib.shell")
local noctalia = require("actions.noctalia")

local mm = binds.make_mod
local bs = binds.bind_scratchpad

local alt = mods.alt
local super = mods.super
local meh = mods.meh

local terminal = apps.terminal
local fileManager = apps.fileManager
local browser = apps.browser

local bind = hl.bind
local exec = hl.dsp.exec_cmd

-- Open terminal and navigation
bind(mm("return", alt), exec(terminal))
bind(mm("return", meh), exec(terminal, { workspace = "special:magic" }))
bind(mm("B", alt), exec(fileManager))
bind(mm("R", alt), exec("$menu"))

-- Specific workspace and multimedia commands
bind(mm("B", meh), exec("stacer", { workspace = 8 }))
bind(mm("Z", meh), exec("hyprctl dispatch workspace 8; easyeffects", { workspace = 8 }))

-- Scratchpad (temporary windows)
bind(mm("D", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-lazydocker.desktop"))
bind(mm("P", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-ncdu.desktop"))
bind(mm("H", meh), exec("dex ~/.local/share/applications/hypr-terminal/hypr-btop.desktop"))
bs(mm("A", alt), "kitty -o background_opacity=0.9 -e yazi", { no_blur = false })
bs(mm("O", meh), "kitty -o background_opacity=1 -e gping google.com")
local fzf = 'kitty -o background_opacity=0.65 -e bash "' .. shell.path("fzf/fzf_explorer") .. '"'
bs(mm("S", meh), fzf)
bs(mm("A", meh), fzf .. " root")
bs(mm("F", meh), fzf .. " file")
bs(mm("G", meh), fzf .. " file root")

-- Menus and widgets
bind(mm("SPACE", alt), exec(noctalia.msg("panel-toggle launcher")))
bind(mm("X", alt), exec(noctalia.msg("panel-toggle session")))
bind(mm("V", alt), exec("dex ~/.local/share/applications/hypr-terminal/hypr-clipse.desktop"))
bind(mm("V", super), exec("clipse-gui"))
bind(mm("SPACE", meh), exec('killall rofi; bash -c "~/.config/rofi/emoji/emoji.sh"'))

-- Browsing
bind(mm("R", meh), exec(browser .. " https://www.startpage.com"))
bind(mm("E", meh), exec(browser .. " https://translate.google.com/?sl=auto&tl=pt"))
