#!/bin/bash
# I should re-write this as a bash function and put in the AlienShuffle script library.

oldName=$1
newName=$2
baseDir="/mnt/c/WSL"
tarFile="$baseDir/$oldName-rename.tar"
newPath="$baseDir/$newName"

wsl.exe --export "$oldName" "$tarFile"
wsl.exe --unregister "$oldName"
mkdir -p "$newPath"
wsl.exe --import "$newName" "$newPath" "$tarFile"
