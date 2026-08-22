function yadm --wraps yadm
    if not command -q yadm
        echo "yadm is not installed" >&2
        return 1
    end

    PYTHONWARNINGS="ignore:pkg_resources is deprecated" command yadm $argv
end
