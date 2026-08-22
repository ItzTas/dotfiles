function mggo
    if not command -q miru
        echo "miru is not installed" >&2
        return 1
    end

    miru go "https://github.com/$argv[1]"
end
