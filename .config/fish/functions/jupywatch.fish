function jupywatch --wraps 'watchmedo shell-command'
    for dep in watchmedo jupytext
        if not command -q $dep
            echo "$dep is not installed" >&2
            return 1
        end
    end

    watchmedo shell-command --patterns='*.py' --command='jupytext --sync ${watch_src_path}' $argv
end
