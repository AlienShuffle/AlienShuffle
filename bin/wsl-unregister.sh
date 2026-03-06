#!/bin/bash
#
# Run the PowerShell script to clone a WSL instance.
#
[ -z "$1" ] && echo "Usage: $0 <instance-name> [<options>]" && exit 1
instance=$1
shift
distros=$(wsl.exe -l -q | iconv -f UTF-16LE -t UTF-8 | tr -d '\r')
if ! grep -Fxq "$instance" <<<"$distros"; then
    echo "$instance distribution not found, valid are: $(echo "$distros" | tr '\n' ',' | sed -e 's/,$//')"
    exit 1
fi
wsl.exe --unregister "$instance" "$@"