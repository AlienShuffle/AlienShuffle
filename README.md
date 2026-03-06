- 👋 Hi, I’m @AlienShuffle
- 👀 I’m interested in automating basic analysis of personal investing. 
-   I also want to modernize my aging coding skills (I've been typing :wq (ZZ for some of you) for almost 40 years)
- 🌱 I’m currently learning Node.js, Javascript, Google App Script, Puppeteer and a bit of python, and rust too.
- 💞️ I’m looking to collaborate on stuff w/ my son.
- 📫 How to reach me readngtndude@gmail.com
- I am also the maintainer of the Bogleheads shared resource call the Money Market Optimizer. this account is used to help build some (now almost all) of the backend. I will be fully including the project here under the CashAnaylzer project.

# Bootstrapping
This repository also holds all my bootstrapping scripts for setting up new Linux environments: bash, npm, etc.

Some sample steps to initialize a new WSL instance.
On your master instance with this respository installed in Ubuntu, scripts directory:
```
# take your reference distro and make a clean copy.
./wsl-copy-distro.sh Ubuntu-24.04 target-instance
# configure the clean copy with the bootstrapping process in this repo.
./wsl-configure-instance.sh target-instance
```
Next items to nail down
- how to easily pull the two optimizer repos or just CashAnalyzer
- how to fix the /etc/hosts issue
- run setupNode.sh in CashAnalyzer.
- use gh auth login for repos to enable cmd line usage.
Here are some WSL-related helpers I provided in the ~/bin from the configure task:
```
# Lists installed WSL distros on this computer.
wsl-list.sh  
# deletes target-instance PERMENANTLY!
wsl-unregister.sh target-instance
# fix when code.exe fails of wsl.exe (requires sudo)
fix-wsl-interop.sh
```
<!---
AlienShuffle/AlienShuffle is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->
