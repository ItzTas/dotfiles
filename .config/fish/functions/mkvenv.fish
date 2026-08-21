function mkvenv
    if test (count $argv) -eq 0
        echo "Please provide venv name"
        return 1
    end

    python3 -m venv "$VENV_HOME/$argv[1]"
end
