#!/bin/bash
#
# Run the basic processes required to initialize a WSL instance for use with AlienShuffle.
# This is designed to be run from powershell or bash source executable as:
# wsl.exe -d <instance-name> -e ./wsl-run-bootstrap.sh
# or
# wsl.exe -d <instance-name> -- bash -s <./wsl-run-bootstrap.sh
#
set -euo pipefail

function clone-github() {
    local REPO_URL="$1"
    local TARGET_DIR="$2"
    echo "=== Cloning or updating repository: $REPO_URL ==="
    if [ ! -d "$TARGET_DIR/.git" ]; then
        echo "Cloning repository into $TARGET_DIR"
        git clone "$REPO_URL" "$TARGET_DIR"
    else
        echo "Repository already exists. Pulling latest changes..."
        git -C "$TARGET_DIR" pull --ff-only
    fi
}

echo "=== Checking for Git installation ==="
if ! command -v git >/dev/null 2>&1; then
    echo "Git not found. Installing..."
    sudo apt-get update -y
    sudo apt-get install -qq -y git
fi
clone-github "https://github.com/AlienShuffle/CashOptimizer.git" "$HOME/cloudflare"
clone-github "https://github.com/AlienShuffle/CashAnalyzer.git" "$HOME/CashAnalyzer"
