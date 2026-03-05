# need to fix the path to the powershell script and the source and clone distro names
powershell.exe -ExecutionPolicy Bypass \
-File /mnt/c/Users/alan/Downloads/Clone-WSL2Distro.ps1 `
  -Source "Ubuntu-24.04" -Clone "U24-lab"
