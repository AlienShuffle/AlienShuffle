#!/bin/bash
set -e

User=gebelea
Instance=Cash-Prod

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -c commands support interactive sudo, so we do here, so that wsl-bootstrap.sh and bootstraps.h can assume passwordless sudo is configured.
# configure WSL instance to use the current user as default, and allow passwordless sudo for apt commands.
wsl.exe -d $Instance -- bash -c 'echo -e "[user]\ndefault='$User'" | sudo tee /etc/wsl.conf >/dev/null'

#allow non-interactive apt calls from default user!
wsl.exe -d $Instance -- bash \
    -c 'echo "'$User' ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" | sudo tee /etc/sudoers.d/cashanalyzer'

wsl.exe -d $Instance -- bash -s <$REPO_ROOT/scripts/wsl-bootstrap.sh
