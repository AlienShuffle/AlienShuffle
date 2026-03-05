#!/bin/bash
# Used to rename a WSL instance. It exports the old instance to a tar file,
# unregisters it, and then imports it with the new name.
[ -z "$1" ] && echo "Usage: $0 <old-name> <new-name>" && exit 1
[ -z "$2" ] && echo "Usage: $0 <old-name> <new-name>" && exit 1
oldName=$1
newName=$2
baseDir="/tmp"
tmpTarFile="$baseDir/$oldName-rename.tar"
newPath="/mnt/c/WSL/$newName"

wsl.exe --export "$oldName" "$tmpTarFile"
wsl.exe --unregister "$oldName"
mkdir -p "$newPath"
wsl.exe --import "$newName" "$newPath" "$tmpTarFile"
echo "Renamed WSL instance '$oldName' to '$newName'."
#rm "$tmpTarFile"
echo "You may want to delete the temporary tar file: $tmpTarFile"