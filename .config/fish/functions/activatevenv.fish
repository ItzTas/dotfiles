function activatevenv
    if test (count $argv) -eq 0
        echo "Please provide venv name"
        return 1
    end

    source "$VENV_HOME/$argv[1]/bin/activate.fish"
end
