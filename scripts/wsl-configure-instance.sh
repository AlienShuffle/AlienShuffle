#!/bin/bash
set -e
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<userid>]" && exit 1
[ -z "$2" ] && echo "userid=gebelea"
instance=$1
userid=${2:-gebelea}

distros=$(wsl.exe -l -q | iconv -f UTF-16LE -t UTF-8 | tr -d '\r')
if ! grep -Fxq "$instance" <<<"$distros"; then
    echo "$instance distribution not found, valid are: $(echo "$distros" | tr '\n' ',' | sed -e 's/,$//')"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -c commands support interactive sudo, so we do here, so that wsl-bootstrap.sh and bootstraps.sh
# can assume passwordless sudo is configured.
# Configure WSL instance to use the current user as default.
echo "=== Configuring WSL instance /etc/wsl.conf to use user: $userid"
wsl.exe -d $instance -- bash \
    -c 'grep -Fxq "default='$userid'" /etc/wsl.conf || (echo -e "[user]\ndefault='$userid'" | sudo tee /etc/wsl.conf >/dev/null)'

echo "=== Configuring WSL instance sudoers to allow passwordless apt-get and apt for user: $userid"
wsl.exe -d $instance -- bash \
    -c 'echo "'$userid' ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" | sudo tee /etc/sudoers.d/cashanalyzer'

echo "=== Kicking off WSL bootstrap processes."
wsl.exe -d $instance -- bash -s <$REPO_ROOT/wsl-run-bootstrap.sh
