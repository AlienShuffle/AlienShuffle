#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! sudo -n /usr/bin/apt-get --version >/dev/null 2>&1; then
  echo "This bootstrap requires passwordless sudo."
  echo "Run once in this environment: sudo visudo"
  echo "Then add the following line to the end of the file"
  echo 'yourusername ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt'
  exit 1
fi

# install a ubuntu packages required by my environment.
if [ ! -f "$REPO_ROOT"/config/apt-packages.txt ]; then
  echo "Package list not found: $REPO_ROOT/config/apt-packages.txt"
  exit 1
fi
echo -e "\n=== updating apt packages ==="
sudo apt-get update -y
echo -e "\n=== installing/verifying required packages ==="
xargs -a "$REPO_ROOT"/config/apt-packages.txt sudo apt-get install -qq -y

# cleanup bad chromium snap package if it exists,
if command -v chromium-browser >/dev/null 2>&1; then
  if [ -d "/snap/chromium" ]; then
    echo -e "\n=== Removing snap chromium package ==="
    sudo snap remove --purge chromium || echo "Failed to remove snap chromium package. Please check manually."
    sudo apt-get purge snapd -y
  fi
fi

# make sure google chrome is installed, since it's required for some of my work.
if ! command -v google-chrome >/dev/null 2>&1; then
  echo -e "\n=== Installing Google Chrome ==="
  tmpdeb="$(mktemp)"
  wget -qO "$tmpdeb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo apt update -y
  sudo apt install -y "$tmpdeb"
  echo rm -f "$tmpdeb"
  rm -f "$tmpdeb"
else
  echo -e "\n=== Updating Google Chrome ==="
  sudo apt-get update -y
  sudo apt-get install -y --only-upgrade google-chrome-stable || true
fi

echo -e "\n=== Cleaning up cruft ==="
sudo apt-get autoremove -y

# install/verify NVM, install LTS NPM instance.
echo -e "\n=== nvm setup ==="
if ! command -v ~/.nvm/nvm.sh >/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
fi
source ~/.nvm/nvm.sh
nvm install --lts

if [ ! -f "$REPO_ROOT"/config/npm-packages.txt ]; then
  echo "Package list not found: $REPO_ROOT/config/apt-packages.txt"
  exit 1
fi
echo -e "\n=== Installing npm packages ==="
xargs -a "$REPO_ROOT"/config/npm-packages.txt npm install -g
npm outdated -g || npm update -g

if [ ! -f "$REPO_ROOT"/config/vscode-extensions.txt ]; then
  echo "VS Code extensions list not found: $REPO_ROOT/config/vscode-extensions.txt"
  exit 1
fi
echo -e "\n=== Installing VS Code extensions ==="
#xargs -a "$REPO_ROOT"/config/vscode-extensions.txt -L 1 code --install-extension
list_file="$REPO_ROOT/config/vscode-extensions.txt"
# Cache installed extensions into a fast lookup (exact IDs, one per line)
installed="$(code --list-extensions)" # prints one id per line
# Install only missing
while IFS= read -r ext || [[ -n "$ext" ]]; do
  ext=$(echo ${ext%$'\r'} | cut -d@ -f1) # strip CR if file is CRLF
  [[ "$ext" =~ ^[[:space:]]*$ ]] && continue
  [[ "$ext" =~ ^[[:space:]]*# ]] && continue
  if ! grep -Fxq "$ext" <<<"$installed"; then
    code --install-extension "$ext"
  fi
done <"$list_file"

# install all bash scripts in ~/bin
echo -e "\n=== Installing ~/bin scripts ==="
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
echo -e "\n=== Installing ~ dot files ==="
SRC_DIR="$REPO_ROOT/dotfiles"
DEST_DIR="$HOME"
find "$DEST_DIR" -xtype l -print -delete
for src in "$SRC_DIR"/.*; do
  name=$(basename "$src")
  ln -sf "$src" "$DEST_DIR/$name"
done

# git setup.
echo -e "\n=== git configuration ==="
git config --global user.email "readngtndude@gmail.com"
git config --global user.name "AlienShuffle ($WSL_DISTRO_NAME@$(hostname))"
# probably need some login credentials process next.

# make sure there is a link to my documents folder in the home directory.
echo -e "\n=== Setting up ~/cdocs link ==="
if [ ! -L ~/cdocs ]; then
  ln -s /mnt/c/Users/alan/OneDrive/Documents/ ~/cdocs
  [ $? -eq 0 ] || echo "Failed to create ~/cdocs link to C:/Users/alan/OneDrive/Documents/"
fi

echo -e "\n=== $0: completed! ==="
