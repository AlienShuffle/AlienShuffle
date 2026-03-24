# includes nvm package in shell.
export NVM_DIR="/home/gebelea/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# WSL related aliases
alias wsl=wsl.exe
alias wsl-default="wsl.exe --set-default"
alias wsl-distros="wsl.exe -l -v"
alias wsl-run="wsl.exe -d"
alias wsl-terminate="wsl.exe --terminate"
alias wsl-unregister="wsl.exe --unregister"