function jupyinit --wraps jupytext
    if not command -q jupytext
        echo "jupytext is not installed" >&2
        return 1
    end

    jupytext --set-formats py:percent,ipynb $argv
end
