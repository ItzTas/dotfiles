_set_gpu_class() {
    set -e

    # Não sobrescreve classe existente
    if yadm config --get local.class >/dev/null 2>&1; then
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

    yadm config local.class "$class"
    echo "[yadm] class set to: $class"
}

_set_up() {
    _set_gpu_class
    yadm submodule update --init --recursive || true
}

_set_up
