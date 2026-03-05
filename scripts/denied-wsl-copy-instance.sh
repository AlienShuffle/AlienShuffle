#!/bin/bash
# Used to rename a WSL instance. It exports the old instance to a tar file,
# unregisters it, and then imports it with the new name.
[ -z "$1" ] && echo "Usage: $0 <curr-instance> <new-instance>" && exit 1
[ -z "$2" ] && echo "Usage: $0 <curr-instance> <new-instance>" && exit 1
oldName=$1
newName=$2
#baseDir="/tmp"
tmpTarFile="/tmp/$oldName-rename.tar"
newPath="/mnt/c/WSL/$newName"

echo "Exporting WSL instance '$oldName' to '$tmpTarFile'..."
wsl.exe --export "$oldName" "$tmpTarFile"
mkdir -p "$newPath"
wsl.exe --import "$newName" "$newPath" "$tmpTarFile"
echo "Copied WSL instance '$oldName' to '$newName'."
rm "$tmpTarFile"
#echo "You may want to delete the temporary tar file: $tmpTarFile"