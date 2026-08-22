function pdeno --wraps deno
    if not command -q proto
        echo "proto is not installed" >&2
        return 1
    end

    proto run deno -- $argv
end
