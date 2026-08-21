function rmvenv
    if test (count $argv) -eq 0
        echo "Please provide venv name"
        return 1
    end

    rm -r "$VENV_HOME/$argv[1]"
end
