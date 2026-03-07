# get Powershell v7.x
Write-Host "###Installing PowerShell 7.x"
winget install --id Microsoft.PowerShell --source winget
# make sure a default instance is running.
Write-Host
Write-Host "###Installing Ubuntu instance"
wsl.exe --install -d Ubuntu
Write-Host
Write-Host "###Updating WSL"
wsl.exe --update
# install Windows Git
Write-Host
Write-Host "###Installing Windows Git"
winget install --id Git.Git -e --source winget