#!/usr/bin/env bash

# Link OpenClaude config to Claude Code config so both tools share the
# same configuration (settings, commands, skills, hooks, plugins, state).
#
# Claude Code reads ~/.claude and ~/.claude.json.
# OpenClaude (a Claude Code fork) reads ~/.openclaude and ~/.openclaude.json.
# Symlinking OpenClaude's paths to Claude's gives full parity between tools.

_set_up() {
    link_one() {
        local target="$1"
        local link_name="$2"

        if [ -L "$link_name" ]; then
            echo "openclaude: symlink already present: $link_name -> $(readlink "$link_name")"
        elif [ -e "$target" ]; then
            if [ -e "$link_name" ] && [ ! -L "$link_name" ]; then
                echo "openclaude: moving existing $link_name to ${link_name}.bak"
                mv "$link_name" "${link_name}.bak"
            fi
            ln -s "$target" "$link_name"
            echo "openclaude: created symlink $link_name -> $target"
        else
            echo "openclaude: SKIP $link_name — $target does not exist yet (nothing to link)" >&2
        fi
    }

    link_one "$HOME/.claude" "$HOME/.openclaude"
    link_one "$HOME/.claude.json" "$HOME/.openclaude.json"
}

_set_up
