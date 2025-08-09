# git
if command -v git &>/dev/null; then
	fe() {
		if ! git rev-parse --is-inside-work-tree &>/dev/null; then
			echo "Error: not in a git directory"
			return 1
		fi

		local b
		b="$(git branch -a | grep -v '\->' | sed 's|remotes/origin/||' | sed 's|^\* ||' | sed 's/^ *//;s/ *$//' | sort -u)"

		echo "$b" | fzf --bind 'ctrl-y:execute(git switch {})+abort'
	}
fi

# fzf
fk() {
	local dir
	dir=$( (
		zoxide query -l
		find . -type d
	) | fzf --preview 'eza --icons --tree --level 3 -F {}') && cd "$dir" || return
}

# tmux
if command -v tmux &>/dev/null; then
	tmux_manager() {
		if [ "$(tmux list-sessions 2>/dev/null | wc -l)" -gt 0 ]; then
			tmux attach
		else
			if ! tmux has-session -t default 2>/dev/null; then
				tmux new-session -s default
			else
				tmux attach-session -t default
			fi
		fi
	}
fi

# sesh
if command -v sesh &>/dev/null; then
	sesh_connect() {
		local selection
		selection=$(
			sesh list --icons | fzf \
				--no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
				--header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
				--bind 'tab:down,btab:up' \
				--bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
				--bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
				--bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
				--bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
				--bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
				--bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
				--preview 'ls {}' \
				--bind 'ctrl-y:accept'
		)
		[[ -n "$selection" ]] && sesh connect "$selection"
	}
fi

# docker
if command -v docker &>/dev/null; then
	fdex() {
		local lines container

		lines="$(docker ps --format "id: {{.ID}}\t name: {{.Names}}\t img: {{.Image}}")"
		container="$(echo "$lines" | fzf --header "exec -it")"

		if [ "$container" != "" ]; then
			local container_name
			container_name=$(echo "$container" | awk '{print $4}')

			docker exec -it "$container_name" bash
		fi
	}
fi

# pacman & utils
upgrady() {
	(
		set -e
		trap 'exit 0' SIGINT
		{
			nohup arch-update --check >/dev/null 2>&1 &
			disown
		} >/dev/null 2>&1

		paru -Syu --devel
		paru -Fy
		pacclean

		flatpak update
		flatpak uninstall --unused

		sudo freshclam
		hyprpm update
		yadm_update

		{
			nohup arch-update --check >/dev/null 2>&1 &
			disown
		} >/dev/null 2>&1
	)
}

pacclean() {
	local orphans
	orphans=$(pacman -Qdtq)

	if [[ -z $orphans ]]; then
		echo "No orphan packages found."
		return
	fi

	local valid_pkgs=()
	for pkg in "${orphans[@]}"; do
		if pacman -Q "$pkg" &>/dev/null; then
			valid_pkgs+=("$pkg")
		fi
	done

	if [[ ${#valid_pkgs[@]} -eq 0 ]]; then
		echo "No valid orphan packages found."
	else
		sudo pacman -Rns "${valid_pkgs[@]}"
	fi
}

# gtk
setgtktheme() {
	gsettings set org.gnome.desktop.interface gtk-theme "$1"
}

seticonstheme() {
	gsettings set org.gnome.desktop.interface icon-theme "$1"
}

# proto & langs
if command -v proto &>/dev/null; then
	pgo() {
		proto run go -- "$@"
	}

	pnode() {
		proto run node -- "$@"
	}

	pbun() {
		proto run bun -- "$@"
	}

	pdeno() {
		proto run deno -- "$@"
	}

	pgleam() {
		proto run gleam -- "$@"
	}

	ppython() {
		proto run python -- "$@"
	}
fi

# miru
if command -v miru &>/dev/null; then
	mggo() {
		miru go "https://github.com/$1"
	}
fi

# file extraction
ex() {
	if [ -f "$1" ]; then
		case "$1" in
		*.tar.bz2) tar xjf "$1" ;;
		*.tar.gz) tar xzf "$1" ;;
		*.bz2) bunzip2 "$1" ;;
		*.rar) unrar x "$1" ;;
		*.gz) gunzip "$1" ;;
		*.tar) tar xf "$1" ;;
		*.tbz2) tar xjf "$1" ;;
		*.tgz) tar xzf "$1" ;;
		*.zip) unzip "$1" ;;
		*.Z) uncompress "$1" ;;
		*.7z) 7za e x "$1" ;;
		*.deb) ar x "$1" ;;
		*.tar.xz) tar xf "$1" ;;
		*.tar.zst) unzstd "$1" ;;
		*) echo "'$1' cannot be listed by ${FUNCNAME[0]}()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

lse() {
	if [ -f "$1" ]; then
		case "$1" in
		*.tar.bz2 | *.tbz2) tar tjf "$1" ;;
		*.tar.gz | *.tgz) tar tzf "$1" ;;
		*.tar.xz) tar tJf "$1" ;;
		*.tar.zst) unzstd -c "$1" | tar tf - ;;
		*.tar) tar tf "$1" ;;
		*.bz2) bunzip2 -l "$1" ;;
		*.gz) gzip -l "$1" ;;
		*.zip) unzip -l "$1" ;;
		*.rar) unrar l "$1" ;;
		*.7z) 7z l "$1" ;;
		*.Z) uncompress -c "$1" | wc -c ;;
		*.deb) ar t "$1" ;;
		*) echo "'$1' cannot be listed by ${FUNCNAME[0]}()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# memory testing
test_memory() {
	local memory="$1"
	if [[ $memory == "" ]]; then
		echo "usage test_memory <num>g"
		return
	fi
	</dev/zero head -c "$memory" | tail
}
