#!/bin/bash
#
# This script is designed to run from powershell or bash source executable as:
# wsl.exe -d Cash-Prod -e ./wsl-bootstrap.sh
# 
set -euo pipefail

REPO_URL="https://github.com/AlienShuffle/AlienShuffle.git"
TARGET_DIR="$HOME/bootstrap"

echo "=== Checking for Git installation ==="
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Installing..."
    sudo apt-get update -y
    sudo apt-get install -y git
else
    echo "Git already installed."
fi

echo "=== Cloning or updating bootstrap repository ==="
if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Cloning repository into $TARGET_DIR"
    git clone "$REPO_URL" "$TARGET_DIR"
else
    echo "Repository already exists. Pulling latest changes..."
    git -C "$TARGET_DIR" pull --ff-only
fi

echo "=== Running bootstrap script if present ==="
if [ -f "$TARGET_DIR/bootstrap.sh" ]; then
    chmod +x "$TARGET_DIR/bootstrap.sh"
    "$TARGET_DIR/bootstrap.sh"
else
    echo "No bootstrap.sh found in repo. Skipping."
fi

echo "=== Done! ==="