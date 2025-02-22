bind -x '"\eg":"lsd -F"'
bind -x '"\ey":"yazi"'
bind -x '"\C-b":f'
bind -x '"\C-o":fe'
# bind -x '"\eb":"pf"'
# bind -x '"\C-f":new_ss'
# bind -x '"\C-a":fs'

if [ -z "$TMUX" ]; then
	bind -x '"\C-f":sesh_connect'
	bind -x '"\C-g":tmux_manager'
fi
