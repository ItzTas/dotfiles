local utils = require("functions.utils")
local shell = require("functions.shell")

local M = {}

function M.area()
    utils.run_async_cmd(shell.inject({ shell.open_path, shell.open_on }, [=[
        filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
        path="$(xdg-user-dir PICTURES)/screenshots"
        fullpath="$path/$filename"

        mkdir -p "$path"

        grim -g "$(slurp)" "$fullpath"

        open_on "sys_print" "$fullpath" "Screenshot saved" "Image saved in $fullpath" "$fullpath"
    ]=]))
end

function M.screen()
    utils.run_async_cmd(shell.inject({ shell.open_path, shell.open_on }, [=[
        filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
        path="$(xdg-user-dir PICTURES)/screenshots"
        fullpath="$path/$filename"

        mkdir -p "$path"

        grim "$fullpath"

        sleep 0.2
        open_on "sys_print" "$fullpath" "Screenshot saved" "Image saved in $fullpath" "$fullpath"
    ]=]))
end

function M.window()
    utils.run_async_cmd(shell.inject({ shell.open_path, shell.open_on }, [=[
        filename="screenshot_$(date '+%Y-%m-%d_%H-%M-%S-%3N').png"
        path="$(xdg-user-dir PICTURES)/screenshots"
        fullpath="$path/$filename"

        mkdir -p "$path"

        hyprshot -m window -s -o "$path" -f "$filename"

        max_retries=20
        retry_interval=0.1
        for ((i = 1; i <= max_retries; i++)); do
            if [ -f "$fullpath" ]; then
                sleep 0.6
                break
            fi
            sleep "$retry_interval"
        done

        open_on "sys_print" "$fullpath" "Screenshot saved" "Image saved in $fullpath" "$fullpath"
    ]=]))
end

return M
