# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Hyprland (Wayland compositor) configuration, version-controlled as part of a [yadm](https://yadm.io/) dotfiles setup. There is no build/test/lint step — changes are validated by reloading the live compositor.

## Two parallel config systems (this is the key thing to understand)

The same configuration exists twice, written two different ways:

1. **`lua/`** — the **active, preferred** source, using Hyprland's newer **hyprlua** API. Entry point `hyprland.lua` sets `package.path` and `require`s every module.
2. **`hyprlang/*.conf`** — the **legacy** path, using classic Hyprland config syntax. Entry point `hyprland.conf` `source`s every `.conf` file.

The two are near 1:1 mirrors of each other (e.g. `lua/settings/misc.lua` ↔ `hyprlang/settings/hyprmisc.conf`). **When changing settings, edit the Lua side.** The `.conf` files are kept around as legacy; only touch them if explicitly asked, and then keep both in sync to avoid drift.

All Lua modules access the compositor through the global `hl` (declared as a known global in `.luarc.json`).

### Core `hl` API patterns

- `hl.config{ section = { key = val } }` — declarative settings, mirrors `.conf` sections (`misc`, `dwindle`, `master`, `plugin.<name>`, …).
- `hl.bind(key, dispatcher, opts)` with `hl.dsp.*` dispatchers (`window`, `exec_cmd`, `focus`, `workspace`, `layout`). See `lua/binds/keymaps.lua`.
- `hl.on("hyprland.start" | "hyprland.shutdown" | "config.reloaded", fn)` — event hooks; `hyprland.start` is the `exec-once` equivalent (see `lua/apps.lua`, `lua/services.lua`, `lua/system-envs.lua`).
- `hl.exec_cmd(cmd, { workspace = N })`, `hl.env`, `hl.monitor`, `hl.window_rule`, `hl.workspace_rule`, `hl.timer`.
- `hl.plugin.<name>` — truthy guard; plugin modules early-`return` if the plugin isn't loaded (see `lua/plugins/hyprexpo.lua`).

## yadm ESH templating

Files named `<target>##template.esh` are yadm **alternate templates** rendered by `yadm alt` into the gitignored target (`hyprapps.conf`, `hyprmonitor.conf`, `hyprenvs.conf`, `hyprservices.conf` — see `hyprlang/.gitignore`). `yadm alt` also runs automatically on `hyprland.start` via `lua/services.lua`.

The `.esh` templates use shell `<% … %>` blocks to branch on hardware at render time (total RAM, GPU vendor). **The Lua path achieves the same conditionals at runtime** via the detection helpers in `lua/functions/` (`ram.has_above`, `gpu.is_nvidia`, `device.is_laptop`) — so hardware-conditional behavior must be updated in both places when both are in play.

## Lua module layout

- `lua/functions/` — pure helpers. Hardware detection (`gpu`, `ram`, `device`) uses multi-strategy fallback chains and is `memoize`d. `utils` has the command runners (`run_cmd`, `run_async_cmd`, `defer`, `memoize`); `binds` builds keybindings (`make_mod`, `bind_scratchpad`, `bind_hold`); `file` is small IO; `shell` injects reusable shell function snippets.
- `lua/envs/` — constants only: `apps` (terminal/browser/file-manager), `mods` (modifier aliases), `notify` (dunst icon dir + notification replace-id).
- `lua/scripts/` — Lua **action** modules (`volume`, `mic`, `spotify`, `print`, `recording`, `ddc`) bound to keys. They assemble shell one-liners and run them async with notifications. These supersede the standalone bash files in the top-level `scripts/` dir, which belong to the legacy `.conf` path.
- `lua/types/` — LuaLS type/enum annotations (e.g. the `Mods` enum).
- `lua/settings/`, `lua/binds/`, `lua/plugins/` — each has an `init.lua` that `require`s its siblings.

## Modifier convention (`lua/envs/mods.lua`)

`alt` is the primary mod, `super` the secondary. `meh` = `ALT+SHIFT+CTRL`, `hyper` = `ALT+SUPER+SHIFT+CTRL`. Workspaces 1–10 are on `alt`, 11–20 on `super` (the loops at the bottom of `keymaps.lua`).

## Common commands

- `hyprctl reload` — apply config changes to the running compositor (always do this after edits).
- `yadm alt` — re-render the `.esh` templates after editing them.
- `hyprctl systeminfo` / `hyprctl version` — inspect the live session; useful when debugging the hardware-detection helpers.
- Lua editing is checked by `lua-language-server` per `.luarc.json` (globals: `hl`; library: `/usr/share/hypr/stubs` + this config's `lua/`). There are no unit tests.
