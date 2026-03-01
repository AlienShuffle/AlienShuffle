# put WSL name in the prompt.
if [ -n "${WSL_DISTRO_NAME-}" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]@[\[\033[01;33m\]${WSL_DISTRO_NAME}\[\033[00m\]@\[\033[01;36m\]\h\[\033[00m\]]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi

# includes nvm package in shell.
export NVM_DIR="/home/gebelea/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
