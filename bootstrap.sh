#!/bin/bash

xargs -a config/apt-packages.txt sudo apt-get install -y

if ! command -v nvm >/dev/null; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

source ~/.nvm/nvm.sh
nvm install --lts

xargs -a config/npm-packages.txt npm install -g
