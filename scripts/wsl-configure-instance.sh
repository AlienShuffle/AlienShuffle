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
[ ! -f "$REPO_ROOT/../config/hosts-template.txt" ] && echo "Missing hosts-template.txt in config directory" && exit 1

# -c commands support interactive sudo, so we do here, so that wsl-bootstrap.sh and bootstraps.sh
# can assume passwordless sudo is configured.

echo -e "\n=== Configuring WSL instance /etc/wsl.conf to to defaults and [user] default=$userid"
wslConfFileString="$(<$REPO_ROOT/../config/wsl-conf-template.txt)
default=$userid"
wString="echo -e '$wslConfFileString' | sudo tee /etc/wsl.conf >/dev/null"
wsl.exe -d $instance -- bash -c "$wString"

echo -e "\n=== Installing our own/etc/hosts to avoid WSL's auto-generated one from interfering with our bootstrap process."
hostsFileString="$(<$REPO_ROOT/../config/hosts-template.txt)
127.0.1.1   $instance.localdomain   $instance
"
cString="echo -e '$hostsFileString' | sudo tee /etc/hosts >/dev/null"
wsl.exe -d $instance -- bash -c "$cString"

echo -e "\n=== Setting hostname to $instance."
wsl.exe -d $instance -- bash -c "sudo hostnamectl set-hostname $instance"

echo -e "\n=== Configuring WSL instance sudoers to allow passwordless apt-get and apt for user: $userid"
wsl.exe -d $instance -- bash \
    -c 'echo "'$userid' ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" | sudo tee /etc/sudoers.d/cashanalyzer >/dev/null'

echo -e "\n=== Kicking off WSL bootstrap processes."
wsl.exe -d $instance -- bash -s <$REPO_ROOT/wsl-run-bootstrap.sh

echo -e "\n=== $0: completed! ==="
