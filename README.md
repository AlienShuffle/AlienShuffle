- 👋 Hi, I’m @AlienShuffle
- 👀 I’m interested in automating basic analysis of personal investing. 
-   I also want to modernize my aging coding skills (I've been typing :wq (ZZ for some of you) for almost 40 years)
- 🌱 I’m currently learning Node.js, Javascript, Google App Script, Puppeteer and a bit of python, and rust too.
- 💞️ I’m looking to collaborate on stuff w/ my son.
- 📫 How to reach me readngtndude@gmail.com
- I am also the maintainer of the Bogleheads shared resource call the Money Market Optimizer. this account is used to help build some (now almost all) of the backend. I will be fully including the project here under the CashAnaylzer project.

# Bootstrapping
This repository also holds all my bootstrapping scripts for setting up new Linux environments: bash, npm, etc.

Some sample (still to be verified) steps to initialize a new WSL instance.
On your master instance with this respository installed in Ubuntu, scripts directory:
```
./wsl-copy-distro.sh Ubuntu-24.04 target-instance
./wsl-
```
Clone this repository into the new Instance
```
 wsl.exe -d Cash-Prod -- bash -c "
        userid=gebelea
        sudo apt-get update -y &&
        sudo apt-get install -y git &&
        if [ ! -d '/home/\$userid/bootstrap/.git' ]; then
            git clone 'https://github.com/AlienShuffle/AlienShuffle.git' '/home/\$userid/bootstrap'
        else
            git -C '$RepoDir' pull --ff-only
        fi
    "

wsl -d Cash-Prod -- bash -c "~/bootstrap/bootstrap.sh"
```
list installed distros:
```
wsl.exe --list --verbose
```
Delete an installed instance:
```
wsl.exe --unregister Cash-Prod
wsl.exe --unregister Cash-Test
```
<!---
AlienShuffle/AlienShuffle is a ✨ special ✨ repository because its `README.md` (this file) appears on your GitHub profile.
You can click the Preview link to take a look at your changes.
--->
