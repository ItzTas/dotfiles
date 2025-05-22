# fzf
fe() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: not in a git directory"
        return 1
    fi

    local b
    b="$(git branch -a | grep -v '\->' | sed 's|remotes/origin/||' | sed 's|^\* ||' | sed 's/^ *//;s/ *$//' | sort -u)"

    echo "$b" | fzf --bind 'ctrl-y:execute(git switch {})+abort'
}

fk() {
    local dir
    dir=$( (
        zoxide query -l
        find . -type d
    ) | fzf --preview 'eza --icons --tree --level 3 -F {}') && cd "$dir" || return
}

# tmux
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

# sesh
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

# docker
fdex() {
    local lines container

    lines="$(docker ps --format "id: {{.ID}}\t name: {{.Names}}\t img: {{.Image}}")"
    container="$(echo "$lines" | fzf --header "exec -it")"

    if [ -n "$container" ]; then
        local container_name
        container_name=$(echo "$container" | awk '{print $4}')

        docker exec -it "$container_name" bash
    fi
}

# pacman & utils
upgrady() {
    {
        nohup arch-update --check >/dev/null 2>&1 &
        disown
    } >/dev/null 2>&1

    paru -Syu --devel
    flatpak update
    sudo freshclam
    paru -Fy
    yadm_update

    {
        nohup arch-update --check >/dev/null 2>&1 &
        disown
    } >/dev/null 2>&1
}

pacclean() {
    local orphans
    orphans=$(pacman -Qdtq)

    if [[ -z $orphans ]]; then
        echo "No orphan packages found."
        return
    fi

    local valid_pkgs=()
    for pkg in $orphans; do
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

# miru
mggo() {
    miru go "https://github.com/$1"
}

# others
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
        *) echo "'$1' cannot be extracted via ex()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
