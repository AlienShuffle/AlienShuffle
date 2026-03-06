#!/bin/bash
#
# Run the PowerShell script to clone a WSL instance.
#
[ -z "$1" ] && echo "Usage: $0 <instance-name> <clone-name> [<options>]" && exit 1
[ -z "$2" ] && echo "Usage: $0 <instance-name> <clone-name> [<options>]" && exit 1
shift; shift

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pwsh.exe \
  -ExecutionPolicy Bypass \
  -File "${REPO_ROOT}/Clone-WSL-Distro.ps1" \
  -Source "$1" \
  -Clone "$2" "$@"