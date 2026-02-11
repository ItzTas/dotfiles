#!/usr/bin/env bash

set -u  # erro se variável não definida

get_release_profile_path() {
    local profiles_ini="$HOME/.zen/profiles.ini"

    if [ ! -f "$profiles_ini" ]; then
        echo "⚠️ profiles.ini não encontrado em $profiles_ini" >&2
        return 1
    fi

    awk '
        /^\[Profile/ { in_profile = 1; path=""; is_release=0 }
        /^Name=Default \(release\)/ && in_profile { is_release=1 }
        /^Path=/ && in_profile { sub(/^Path=/,"",$0); path=$0 }
        is_release && path { print path; exit }
    ' "$profiles_ini"
}

create_symlinks() {
    local misc_zen_dir zen_dir profile_path slink

    misc_zen_dir="$HOME/.config/yadm/misc/zen-browser/symlinks"

    # pega o path do profile release
    profile_path=$(get_release_profile_path) || {
        echo "⚠️ Não foi possível encontrar o profile release" >&2
        return 1
    }

    zen_dir="$HOME/.zen/$profile_path"

    # garante que o diretório exista
    mkdir -p "$zen_dir"

    echo "➡️ Symlinks serão criados em: $zen_dir"

    # percorre cada arquivo ou pasta
    for slink in "$misc_zen_dir"/*; do
        # ignora se não existir nada
        [ -e "$slink" ] || continue

        # se for diretório, usa -d para symlink com overwrite
        if [ -d "$slink" ]; then
            ln -sfd "$slink" "$zen_dir" 2>/dev/null || \
                echo "⚠️ Falha ao criar symlink para diretório: $slink"
        else
            ln -sf "$slink" "$zen_dir" 2>/dev/null || \
                echo "⚠️ Falha ao criar symlink para arquivo: $slink"
        fi
    done

    echo "✅ Todos os symlinks processados."
}

create_symlinks

