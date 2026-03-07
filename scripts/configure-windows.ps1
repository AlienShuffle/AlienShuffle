# get Powershell v7.x
winget install --id Microsoft.PowerShell --source winget
# make sure a default instance is running.
wsl.exe --install -d Ubuntu
wsl.exe --update
# install Windows Git
winget install --id Git.Git -e --source winget