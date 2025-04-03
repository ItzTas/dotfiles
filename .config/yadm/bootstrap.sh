#!/bin/bash

# Save this file as ~/.config/yadm/bootstrap and make it executable. It will
# execute all executable files (excluding templates and editor backups) in the
# ~/.config/yadm/bootstrap.d directory when run.

set -eu

# Directory to look for bootstrap executables in
BOOTSTRAP_D="$HOME/.config/yadm/bootstrap.x.d"

if [[ ! -d "$BOOTSTRAP_D" ]]; then
    echo "Error: bootstrap directory '$BOOTSTRAP_D' not found" >&2
    exit 1
fi

chmod +x "$BOOTSTRAP_D/stash.sh"
chmod +x "$BOOTSTRAP_D/install_packages.sh"
chmod +x "$BOOTSTRAP_D/enables.sh"
chmod +x "$BOOTSTRAP_D/grub_theme.sh"

"$BOOTSTRAP_D/stash.sh"
"$BOOTSTRAP_D/install_packages.sh"
"$BOOTSTRAP_D/enables.sh"
"$BOOTSTRAP_D/grub_theme.sh"
