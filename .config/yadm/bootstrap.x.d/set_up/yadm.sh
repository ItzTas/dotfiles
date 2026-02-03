yadm() {
    PYTHONWARNINGS="ignore:pkg_resources is deprecated" command yadm "$@"
}

has_yadm_class() {
    local regex="$1"
    local classes
    classes=$(yadm config --get-all local.class 2>/dev/null || true)

    for c in "${classes[@]}"; do
        if [[ "$c" =~ $regex ]]; then
            return 0
        fi
    done

    return 1
}

set_gpu_class() {
    set -e

    if has_yadm_class '^gpu'; then
        echo "[yadm] GPU class already set"
        return 0
    fi

    local class=""
    if command -v lspci >/dev/null 2>&1 && lspci | grep -qi nvidia; then
        class="gpu-nvidia"
        echo "[yadm] detected NVIDIA GPU"
    else
        class="gpu-other"
        echo "[yadm] detected non-NVIDIA GPU"
    fi

    yadm config --add local.class "$class"
    echo "[yadm] gpu class set to: $class"
}

set_device_class() {
    set -e

    local device_class

    if command -v laptop-detect >/dev/null 2>&1 && laptop-detect >/dev/null 2>&1; then
        device_class="laptop"
    else
        device_class="desktop"
    fi

    if has_yadm_class "$device_class"; then
        echo "[yadm] device class already set: $device_class"
    else
        yadm config --add local.class "$device_class"
        echo "[yadm] device class set to: $device_class"
    fi
}

set_up() {
    set_gpu_class
    set_device_class
    yadm submodule update --init --recursive || true
    yadm alt
}

set_up
