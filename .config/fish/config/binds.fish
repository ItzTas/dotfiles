for mode in default insert
    bind -M $mode alt-g lsd_widget
    bind -M $mode alt-y yazi_widget
    bind -M $mode ctrl-o fe_widget

    bind -M $mode ctrl-a beginning-of-line
    bind -M $mode ctrl-e end-of-line
    bind -M $mode ctrl-b yank
    bind -M $mode ctrl-d delete-char
    bind -M $mode ctrl-w backward-kill-word
    bind -M $mode ctrl-h backward-kill-word
    bind -M $mode alt-d kill-word
    bind -M $mode alt-b backward-word
    bind -M $mode alt-f forward-word
    bind -M $mode ctrl-l clear-screen
    bind -M $mode ctrl-k kill-line
    bind -M $mode ctrl-right forward-word
    bind -M $mode ctrl-left backward-word

    bind -M $mode home beginning-of-line
    bind -M $mode end end-of-line

    bind -M $mode ctrl-y accept-autosuggestion
    bind -M $mode tab complete
    bind -M $mode shift-tab complete-and-search

    bind -M $mode up history-search-backward
    bind -M $mode down history-search-forward

    bind -M $mode alt-. history-token-search-backward
    bind -M $mode ctrl-x copybuffer
end

bind -M default k history-search-backward
bind -M default j history-search-forward
