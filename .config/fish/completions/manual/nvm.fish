complete -c nvm -f

complete -c nvm -n __fish_use_subcommand -a install -d 'download and install a version'
complete -c nvm -n __fish_use_subcommand -a uninstall -d 'uninstall a version'
complete -c nvm -n __fish_use_subcommand -a use -d 'switch to a version in this shell'
complete -c nvm -n __fish_use_subcommand -a exec -d 'run a command with a version'
complete -c nvm -n __fish_use_subcommand -a run -d 'run node with a version'
complete -c nvm -n __fish_use_subcommand -a current -d 'show the active version'
complete -c nvm -n __fish_use_subcommand -a ls -d 'list installed versions'
complete -c nvm -n __fish_use_subcommand -a ls-remote -d 'list versions available to install'
complete -c nvm -n __fish_use_subcommand -a version -d 'resolve a version alias locally'
complete -c nvm -n __fish_use_subcommand -a version-remote -d 'resolve a version alias remotely'
complete -c nvm -n __fish_use_subcommand -a deactivate -d 'drop the active version from PATH'
complete -c nvm -n __fish_use_subcommand -a alias -d 'set or show an alias'
complete -c nvm -n __fish_use_subcommand -a unalias -d 'delete an alias'
complete -c nvm -n __fish_use_subcommand -a install-latest-npm -d 'upgrade npm to the latest supported'
complete -c nvm -n __fish_use_subcommand -a reinstall-packages -d 'reinstall global packages from another version'
complete -c nvm -n __fish_use_subcommand -a unload -d 'remove nvm from the shell'
complete -c nvm -n __fish_use_subcommand -a which -d 'show the path to a version'
complete -c nvm -n __fish_use_subcommand -a cache -d 'manage the download cache'
complete -c nvm -n __fish_use_subcommand -a set-colors -d 'set the output colors'

complete -c nvm -n '__fish_seen_subcommand_from uninstall use exec run version which reinstall-packages' \
    -a '(path basename (path filter -d -- $NVM_DIR/versions/node/*))' -d 'installed version'

complete -c nvm -n '__fish_seen_subcommand_from use exec run version which install alias' \
    -a '(path basename (path filter -f -- $NVM_DIR/alias/* $NVM_DIR/alias/*/*) | string match -rv "^\\*\$")' -d alias

complete -c nvm -n '__fish_seen_subcommand_from unalias' \
    -a '(path basename (path filter -f -- $NVM_DIR/alias/*) | string match -rv "^\\*\$")' -d alias

complete -c nvm -n '__fish_seen_subcommand_from cache' -a 'dir clear' -d 'cache action'

complete -c nvm -n __fish_use_subcommand -s h -l help -d 'show usage'
complete -c nvm -n __fish_use_subcommand -s v -l version -d 'show the nvm version'
