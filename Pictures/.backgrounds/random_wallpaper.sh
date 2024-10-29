#!/bin/bash

choose_random() {
    local files
    mapfile -t files < <(ls -d ~/Pictures/.backgrounds/*)

    local choosen_file
    choosen_file="${files[RANDOM % ${#files[@]}]}"

    if [[ -d $choosen_file ]]; then
        choose_random
        return
    fi

    feh --bg-scale "$choosen_file"
}

choose_random

unset choose_random
