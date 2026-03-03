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

# install all bash scripts in ~/bin
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$REPO_ROOT/bin"
DEST_DIR="$HOME/bin"
mkdir -p "$DEST_DIR"

for src in "$SRC_DIR"/*; do
  [ -x "$src" ] || continue
  name=$(basename "$src")
  ln -sf "$src" "$DEST_DIR/$name"
done

# install dot files in home directory
SRC_DIR="$REPO_ROOT/dotfiles"
DEST_DIR="$HOME"
for src in "$SRC_DIR"/.*; do
  name=$(basename "$src")
  ln -sf "$src" "$DEST_DIR/$name"
done

# git setup.
git config --global user.email "readngtndude@gmail.com"
git config --global user.name "AlienShuffle ($WSL_DISTRO_NAME@$(hostname))"

