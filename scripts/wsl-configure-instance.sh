#!/bin/bash
set -e
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<userid>]" && exit 1
[ -z "$2" ] && echo "userid=gebelea"
instance=$1
userid=${2:-gebelea}

# Always use wsl.exe (works from both Windows and WSL via interop)
WSL_CMD="wsl.exe"

distros=$($WSL_CMD -l -q 2>/dev/null | tr -d '\000' | tr -d '\r')
if ! grep -Fxq "$instance" <<<"$distros"; then
    echo "$instance distribution not found, valid are: $(echo "$distros" | tr '\n' ',' | sed -e 's/,$//')"
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[ ! -f "$REPO_ROOT/../config/wsl-conf-template.txt" ] && echo "Missing wsl-conf-template.txt in config directory" && exit 1

echo -e "\n=== Configuring WSL instance /etc/wsl.conf to defaults, hostname, and [user] default=$userid"
# Create a temp file locally, then copy content into target via base64 to avoid path issues
tmpFile=$(mktemp)
cat "$REPO_ROOT/../config/wsl-conf-template.txt" > "$tmpFile"
echo "hostname=$instance" >> "$tmpFile"
echo "" >> "$tmpFile"
echo "[user]" >> "$tmpFile"
echo "default=$userid" >> "$tmpFile"
encodedConf=$(base64 -w0 < "$tmpFile")
$WSL_CMD -u root -d $instance -- bash -c "echo '$encodedConf' | base64 -d | tee /etc/wsl.conf"
rm -f "$tmpFile"

echo -e "\n=== Configuring WSL instance sudoers to allow passwordless sudo for user: $userid"
$WSL_CMD -u root -d $instance -- bash -c "echo '$userid ALL=(ALL) NOPASSWD: ALL' | tee /etc/sudoers.d/cashanalyzer && chmod 440 /etc/sudoers.d/cashanalyzer"

echo -e "\n=== Kicking off WSL bootstrap processes."
cat "$REPO_ROOT/prep-run-bootstrap.sh" | $WSL_CMD -d $instance -- bash -s

echo -e "\n=== $0: completed! ==="
