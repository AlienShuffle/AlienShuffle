#!/bin/bash
set -e
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<userid>]" && exit 1
[ -z "$2" ] && echo "userid=gebelea"
instance=$1
userid=${2:-gebelea}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -c commands support interactive sudo, so we do here, so that wsl-bootstrap.sh and bootstraps.sh
# can assume passwordless sudo is configured.
# Configure WSL instance to use the current user as default.
wsl.exe -d $instance -- bash -c 'echo -e "[user]\ndefault='$userid'" | sudo tee /etc/wsl.conf >/dev/null'

# Allow non-interactive apt calls from default user!
wsl.exe -d $instance -- bash \
    -c 'echo "'$userid' ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" | sudo tee /etc/sudoers.d/cashanalyzer'

# kick off the WSL boot strap processes.
wsl.exe -d $instance -- bash -s <$REPO_ROOT/scripts-bash/wsl-run-bootstrap.sh
