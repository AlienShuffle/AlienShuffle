#!/bin/bash
#
# Run the PowerShell script to clone a WSL instance.
#
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<options>]" && exit 1
instance=$1
shift
wsl.exe --unregister "$instance" "$@"