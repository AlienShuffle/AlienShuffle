#get latest WSL distro from Microsoft.
wsl.exe --update

# use APT to keep the ubuntu package distros updated.
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y

# npm updates
#npm update && npm upgrade
npm outdated -g || npm update -g

# update rust
#rustup update
