local utils = require("functions.utils")
local shell = require("functions.shell")

local M = {}

function M.toggle()
    utils.run_async_cmd(shell.inject({ shell.open_path, shell.open_on }, [=[
        focused_monitor() {
            local monitors
            monitors=$(hyprctl monitors -j)

            local name
            name=$(jq -r 'first(.[] | select(.focused)) | .name // empty' <<<"$monitors")

            if [[ -z "$name" ]]; then
                name=$(jq -r '.[0].name // empty' <<<"$monitors")
            fi

            printf '%s' "$name"
        }

        record_gpu() {
            local monitor="$1"
            local output="$2"

            command -v gpu-screen-recorder >/dev/null 2>&1 || return 1

            gpu-screen-recorder -w "$monitor" -c mp4 -f 60 -a default_output -o "$output" && return 0

            # A non-zero exit with a written file means it recorded and then died on
            # shutdown; only a missing/empty file is a real startup failure.
            [[ -s "$output" ]]
        }

        record_wf() {
            local monitor="$1"
            local output="$2"

            wf-recorder -o "$monitor" -f "$output"
        }

        if pgrep -x gpu-screen-recorder >/dev/null || pgrep -x wf-recorder >/dev/null; then
            killall -q -s INT gpu-screen-recorder
            killall -q -s INT wf-recorder
            exit 0
        fi

        monitor=$(focused_monitor)
        if [[ -z "$monitor" ]]; then
            dunstify -a "sys_recording" "Error" "Could not detect the focused monitor"
            exit 1
        fi

        dir="$HOME/Videos/.recordings/system"
        mkdir -p "$dir"

        filename="$dir/recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"
        basename=$(basename "$filename")

        notify-send -a "sys_recording" "Recording Started" "Recording $monitor to $filename" || exit 1

        if ! record_gpu "$monitor" "$filename"; then
            rm -f "$filename"

            if ! record_wf "$monitor" "$filename"; then
                dunstify -a "sys_recording" "Error" "Failed to start recording on $monitor"
                exit 1
            fi
        fi

        tmpdir=$(mktemp -d)
        thumbnail="$tmpdir/thumbnail.png"

        if ! ffmpeg -y -i "$filename" -vframes 1 "$thumbnail"; then
            dunstify -a "sys_recording" "Error" "Failed to generate thumbnail"
            rm -rf "$tmpdir"
            exit 1
        fi

        open_on "sys_recording" "$thumbnail" "Recording Finished" "The recording has been saved as $basename" "$filename"

        rm -rf "$tmpdir"
    ]=]))
end

return M
