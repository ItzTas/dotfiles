#!/bin/bash

trimmed_path=$(echo "$NEMO_SCRIPT_SELECTED_FILE_PATHS" | sed 's/^[ \t]*//;s/[ \t]*$//')

scr="
new_ss() {
    local direc
    direc=\$(pwd)
    direc=\"\${direc##*( )}\"
    direc=\"\${direc%%*( )}\"
    if [[ -z \"\$direc\" ]]; then
        return 0
    fi

    local d
    d=\"\$(basename \"\$(pwd)\")\"
    d=\"\${d//./_}\"

    tmux new-session -d -s \"\$d\"
    while ! tmux has-session -t \"\$d\"; do
        sleep 0.01
    done

    tmux attach-session -t \"\$d\"
}

new_ss
"

if [ -n "$trimmed_path" ]; then
    kitty --directory="$(dirname "$trimmed_path")" "$trimmed_path" bash -c "$scr"
else
    kitty --directory="$(pwd)" bash -c "$scr"
fi
