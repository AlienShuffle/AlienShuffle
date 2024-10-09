run-updates
# look latestdistribution upgrade is available.
sudo apt dist-upgrade
# ensure we have latest update mananger
sudo apt install update-manager-core
# runs the actuall update
sudo do-release-upgrade -d


# Revised proposed process for 22.04 to 24.04
sudo apt update && sudo apt full-upgrade
# close down WSL and run these form the PowerShell
wsl -l -v 
# Confirm the distribution name and adjust below if needed
wsl --terminate Ubuntu
