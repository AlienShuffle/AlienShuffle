#!/bin/bash
set -e
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<userid>]" && exit 1
[ -z "$2" ] && echo "userid=gebelea"
instance=$1
userid=${2:-gebelea}

distros=$(wsl.exe -l -q | tr -d '\000' | tr -d '\r')
if ! grep -Fxq "$instance" <<<"$distros"; then
    echo "$instance distribution not found, valid are: $(echo "$distros" | tr '\n' ',' | sed -e 's/,$//')"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ ! -f "$REPO_ROOT/../config/wsl-conf-template.txt" ] && echo "Missing wsl-conf-template.txt in config directory" && exit 1

# -c commands support interactive sudo, so we do here, so that wsl-bootstrap.sh and bootstraps.sh
# can assume passwordless sudo is configured and run unattended.

echo -e "\n=== Configuring WSL instance /etc/wsl.conf to defaults, hostname, and [user] default=$userid"
wslConfFileString="$(<$REPO_ROOT/../config/wsl-conf-template.txt)
hostname=$instance

[user]
default=$userid"
wsl.exe -d $instance -- bash -c "echo '$wslConfFileString' | sudo tee /etc/wsl.conf >/dev/null" 2>/dev/null || true

echo -e "\n=== Configuring WSL instance sudoers to allow passwordless sudo for user: $userid"
echo "$userid ALL=(ALL) NOPASSWD: ALL" | wsl.exe -d $instance -- bash -c "cat | sudo tee /etc/sudoers.d/cashanalyzer >/dev/null && sudo chmod 440 /etc/sudoers.d/cashanalyzer" 2>/dev/null || true

echo -e "\n=== Kicking off WSL bootstrap processes."
wsl.exe -d $instance -- bash -s <$REPO_ROOT/prep-run-bootstrap.sh

echo -e "\n=== $0: completed! ==="
