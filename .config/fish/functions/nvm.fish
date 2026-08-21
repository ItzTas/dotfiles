function nvm
    if command -q bass
        bass source "$NVM_DIR/nvm.sh" --no-use ';' nvm $argv
        return $status
    end

    echo "nvm is a bash script and cannot be sourced by fish." >&2
    echo "Install a bridge (edc/bass) or the native port (jorgebucaran/nvm.fish)." >&2
    return 1
end
