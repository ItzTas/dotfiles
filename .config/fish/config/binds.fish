#!/usr/bin/env fish

function __bind -a modes
    for mode in (string split , -- $modes)
        bind -M $mode $argv[2..]
    end
end

# Key sequences
set -g fish_sequence_key_delay_ms 300

# Widgets
__bind default,insert alt-g lsd_widget
__bind default,insert alt-y yazi_widget
__bind default,insert ctrl-o fe_widget

__bind default,insert alt-c dirh_widget
__bind default,insert alt-left prevd_widget
__bind default,insert alt-right nextd_widget

if test -z "$TMUX"
    command -q tmux; and __bind default,insert ctrl-g tmux_manager_widget
    command -q sesh; and __bind default,insert ctrl-f sesh_connect_widget
end

# Line editing
__bind default,insert,visual ctrl-c cancel_line_widget
__bind default,insert ctrl-a beginning-of-line
__bind default,insert ctrl-e end-of-line
__bind default,insert ctrl-b yank
__bind default,insert ctrl-d delete-char
__bind default,insert ctrl-w backward-kill-word
__bind default,insert ctrl-h backward-kill-word
__bind default,insert alt-d kill-word
__bind default,insert alt-b backward-word
__bind default,insert alt-f forward-word
__bind default,insert ctrl-l clear-screen
__bind default,insert ctrl-k kill-line
__bind default,insert ctrl-right forward-word
__bind default,insert ctrl-left backward-word

__bind default,insert home beginning-of-line
__bind default,insert end end-of-line

# Completion
__bind default,insert ctrl-y accept-autosuggestion
__bind default,insert tab complete
__bind default,insert shift-tab complete-and-search

# History
__bind default,insert up history-search-backward
__bind default,insert down history-search-forward

__bind default,insert alt-. history-token-search-backward

__bind default k history-search-backward
__bind default j history-search-forward

functions --erase __bind
