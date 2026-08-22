function pgleam --wraps gleam
    if not command -q proto
        echo "proto is not installed" >&2
        return 1
    end

    proto run gleam -- $argv
end
