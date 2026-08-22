function ubw
    if not command -q bw
        echo "bw is not installed" >&2
        return 1
    end

    set -gx BW_SESSION (bw unlock --raw)
end
