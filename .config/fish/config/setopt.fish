#!/usr/bin/env fish

# Greeting
set -g fish_greeting

# History scope
if set -q FISH_HISTORY_SCOPE; and test -n "$FISH_HISTORY_SCOPE"
    histscope "$FISH_HISTORY_SCOPE" >/dev/null
else if set -q FISH_HISTORY_PER_TMUX; and set -q TMUX
    histscope --tmux >/dev/null
end
