#!/bin/bash
set -e

# install a ubuntu packages required by my environment.
if [ ! -f config/apt-packages.txt ]; then
  echo "Package list not found: config/apt-packages.txt"
  exit 1
fi
sudo apt-get update -y
xargs -a config/apt-packages.txt sudo apt-get install -y

if ! command -v nvm >/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi
source ~/.nvm/nvm.sh
nvm install --lts

if [ ! -f config/npm-packages.txt ]; then
  echo "Package list not found: config/apt-packages.txt"
  exit 1
fi
xargs -a config/npm-packages.txt npm install -g
npm outdated -g || npm update -g

# This works
for i in dotfiles/.*; do
  file=$(basename $i)
  if [ ! -f $file ]; then
    echo $file missing
    (
      cd ..
      ln -s bootstrap/dotfiles/$file
    )
  fi
done

# git setup.
git config --global user.email "readngtndude@gmail.com"
git config --global user.name "AlienShuffle ($WSL_DISTRO_NAME@$(hostname))"
