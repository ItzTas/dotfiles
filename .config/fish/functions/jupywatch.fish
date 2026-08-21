function jupywatch
    watchmedo shell-command --patterns='*.py' --command='jupytext --sync ${watch_src_path}' $argv
end
