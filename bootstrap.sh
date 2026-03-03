#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# install a ubuntu packages required by my environment.
if [ ! -f "$REPO_ROOT"/config/apt-packages.txt ]; then
  echo "Package list not found: $REPO_ROOT/config/apt-packages.txt"
  exit 1
fi
echo "=== updating apt packages ==="
sudo apt-get update -y
echo "=== installing/verifying required packages ==="
xargs -a "$REPO_ROOT"/config/apt-packages.txt sudo apt-get install -y

# install/verify NVM, install LTS NPM instance.
echo "=== nvm setup ==="
if ! command -v ~/.nvm/nvm.sh >/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi
source ~/.nvm/nvm.sh
nvm install --lts

if [ ! -f "$REPO_ROOT"/config/npm-packages.txt ]; then
  echo "Package list not found: $REPO_ROOT/config/apt-packages.txt"
  exit 1
fi
echo "=== Installing npm packages ==="
xargs -a "$REPO_ROOT"/config/npm-packages.txt npm install -g
npm outdated -g || npm update -g

# install all bash scripts in ~/bin
echo "=== Installing ~/bin scripts ==="
SRC_DIR="$REPO_ROOT/bin"
DEST_DIR="$HOME/bin"
mkdir -p "$DEST_DIR"
find "$DEST_DIR" -xtype l -delete
for src in "$SRC_DIR"/*; do
  [ -x "$src" ] || continue
  name=$(basename "$src")
  ln -sf "$src" "$DEST_DIR/$name"
done

# install dot files in home directory
echo "=== Installing ~ dot files ==="
SRC_DIR="$REPO_ROOT/dotfiles"
DEST_DIR="$HOME"
find "$DEST_DIR" -xtype l -delete
for src in "$SRC_DIR"/.*; do
  name=$(basename "$src")
  ln -sf "$src" "$DEST_DIR/$name"
done

# git setup.
echo "=== git configuration ==="
git config --global user.email "readngtndude@gmail.com"
git config --global user.name "AlienShuffle ($WSL_DISTRO_NAME@$(hostname))"
# probably need some login credentials process next.

echo "=== $0: completed! ==="