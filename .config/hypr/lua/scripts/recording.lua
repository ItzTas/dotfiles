local utils = require("functions.utils")
local shell = require("functions.shell")

local M = {}

function M.toggle()
    utils.run_async_cmd(shell.inject({ shell.open_path, shell.open_on }, [=[
        if pgrep wf-recorder >/dev/null; then
            killall -q wf-recorder
            exit 0
        fi

        dir="$HOME/Videos/.recordings/system"
        mkdir -p "$dir"

        filename="$dir/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
        basename=$(basename "$filename")

        notify-send -a "sys_recording" "Recording Started" "Recording to $filename" || exit 1

        if ! wf-recorder -f "$filename"; then
            dunstify "Error" "Failed to start recording"
            exit 1
        fi

        tmpdir=$(mktemp -d)
        thumbnail="$tmpdir/thumbnail.png"
        rm -f "$thumbnail"

        if ! ffmpeg -y -i "$filename" -vframes 1 "$thumbnail"; then
            dunstify "Error" "Failed to generate thumbnail"
            rm -rf "$tmpdir"
            exit 1
        fi

        open_on "sys_recording" "$thumbnail" "Recording Finished" "The recording has been saved as $basename" "$filename"

        rm -rf "$tmpdir"
    ]=]))
end

return M
