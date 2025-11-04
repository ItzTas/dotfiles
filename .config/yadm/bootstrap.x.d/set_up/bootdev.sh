#!/usr/bin/env bash

_set_up_colors() {
    local colors
    colors=$(
        cat <<'EOF'
color:
  gray: "223"
  green: "153"
  red: "167"
EOF
    )

    if ! grep -qF 'gray: "223"' "$HOME/.bootdev.yaml" ||
        ! grep -qF 'green: "153"' "$HOME/.bootdev.yaml" ||
        ! grep -qF 'red: "167"' "$HOME/.bootdev.yaml"; then
        echo "$colors" >"$HOME/.bootdev.yaml"
        echo "Colors added to the file."
    else
        echo "The file already has the specified colors. No changes made."
    fi
}

_set_up() {
    _set_up_colors
}

_set_up
