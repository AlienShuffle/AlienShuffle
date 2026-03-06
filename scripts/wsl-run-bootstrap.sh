#!/bin/bash
#
# Run the basic processes required to initialize a WSL instance for use with AlienShuffle.
# This is designed to be run from powershell or bash source executable as:
# wsl.exe -d <instance-name> -e ./wsl-run-bootstrap.sh
# or
# wsl.exe -d <instance-name> -- bash -s <./wsl-run-bootstrap.sh
# 
set -euo pipefail

if ! sudo -n /usr/bin/apt-get --version >/dev/null 2>&1; then
  echo "This bootstrap requires passwordless sudo."
  echo "Run once in this environment: sudo visudo"
  echo "Then add the following line to the end of the file"
  echo 'yourusername ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt'
  exit 1
fi

REPO_URL="https://github.com/AlienShuffle/AlienShuffle.git"
TARGET_DIR="$HOME/bootstrap"

echo -e "\n=== Checking for Git installation ==="
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Installing..."
    sudo apt-get update -y
    sudo apt-get install -qq -y git
else
    echo "Git already installed."
fi

echo -e "\n=== Cloning or updating bootstrap repository ==="
if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Cloning repository into $TARGET_DIR"
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "Repository already exists. Pulling latest changes..."
    git -C "$TARGET_DIR" pull --ff-only
fi

echo -e "\n=== Running bootstrap script if present ==="
if [ -f "$TARGET_DIR/bootstrap.sh" ]; then
    chmod +x "$TARGET_DIR/bootstrap.sh"
    "$TARGET_DIR/bootstrap.sh"
else
    echo "No bootstrap.sh found in repo. Skipping."
fi

echo -e "\n=== wsl-run-bootstrap.sh: completed! ==="