# get Powershell v7.x
echo "###Installing PowerShell 7.x"
winget install --id Microsoft.PowerShell --source winget
# make sure a default instance is running.
echo
echo "###Installing Ubuntu instance"
wsl.exe --install -d Ubuntu
echo
echo "###Updating WSL"
wsl.exe --update
# install Windows Git
echo
echo "###Installing Windows Git"
winget install --id Git.Git -e --source winget