- 👋 Hi, I’m @AlienShuffle
- 👀 I’m interested in automating basic analysis of personal investing. 
-   I also want to modernize my aging coding skills (I've been typing :wq (ZZ for some of you) for almost 40 years)
- 🌱 I’m currently learning Node.js, Javascript, Google App Script, Puppeteer and a bit of python, and rust too.
- 💞️ I’m looking to collaborate on stuff w/ my son.
- 📫 How to reach me readngtndude@gmail.com
- I am also the maintainer of the Bogleheads shared resource call the Money Market Optimizer. this account is used to help build some (now almost all) of the backend. I will be fully including the project here under the CashAnaylzer project.

# Bootstrapping
This repository also holds all my bootstrapping scripts for setting up new Linux environments: bash, npm, etc.

## Steps to initialize a new WSL instance to produce a DevOps environment from a fresh Win11 box
Prerequisites are documented in `scripts/configure-windows.ps1`
- If you pull down the script.
```
powershell.exe configure-windows.ps1
```
Run the next block in Powershell 7 (not Windows Powershell)
- Grab your preferred reference WSL distro.
```
wsl.exe --install Ubuntu-24.04
mkdir C:\WSL
cd C:\WSL
```
- Pull the boostrap repository
```
& "C:\Program Files\Git\bin\git" clone 'https://github.com/AlienShuffle/AlienShuffle.git' .\bootstrap
```
- Clone distro - don't work in the original downloaded instance, keep it clean.
```
cd .\bootstrap\scripts\
pwsh .\Clone-WSL-Distro.ps1 -Source Ubuntu-24.04 -Clone master
& "C:\Program Files\Git\bin\bash" wsl-configure-instance.sh master
```
The bootstrap full run will likely fail, but the initial config steps are done. The rest can be done within `master`.
```
wsl.exe -d master
```
# Instance master started, run in `master` from now on.
- It is possible that git is not installed on some distros. You may need to run git install first.
```
command -v git || sudo apt-get install -qq -y git
```
- Clone bootstrap repo
```
git clone 'https://github.com/AlienShuffle/AlienShuffle.git' ~/bootstrap
```
- Make sure all core setup is complete, then calls ../bootstrap.sh
```
cd ~/bootstrap/scripts
./prep-run-bootstrap.sh
```
# Now we work in the `master` instance with this respository
Repeat these steps three times for `dev`, `testing`, and `production`
- Take your reference distro and make a clean copy by duplicating it
```
cd ~/boostrap/scripts
./wsl-copy-distro.sh Ubuntu-24.04 dev
```
- Configure the new copy with the bootstrapping process in this repo.
```
./wsl-configure-instance.sh dev
```
- Install CashAnalyzer Repo
```
git clone 'https://github.com/AlienShuffle/CashAnalyzer.git' ~/CashAnalyzer
```
- Initialize the node packages and authenticate
```
cd ~/CashAnalyzer
./setupNode.sh
gh auth login
gh auth setup-git
```
- Clone cloudflare repo only on `production` instance
```
git clone 'https://github.com/AlienShuffle/CashOptimizer.git' ~/cloudflare
```
<!---
AlienShuffle/AlienShuffle is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->
