# ================================
# CONFIGURATION
# ================================
$BaseDistroName = "Ubuntu-24.04"                     # The base Ubuntu you installed
$BaseTar        = "C:\WSL\ubuntu-24.04-base.tar"     # Where to store the exported tar
$ProdName       = "Cash-Prod"
$TestName       = "Cash-Test"
$ProdDir        = "C:\WSL\$ProdName"
$TestDir        = "C:\WSL\$TestName"

$DefaultUser    = "gebelea"                    # Your Linux username
$RepoURL        = "https://github.com/AlienShuffle/AlienShuffle.git"
$RepoDir        = "/home/$DefaultUser/bootstrap"

# ================================
# EXPORT BASE DISTRO
# ================================
Write-Host "Exporting base distro '$BaseDistroName'..."
if (!(Test-Path $BaseTar)) {
    wsl --export $BaseDistroName $BaseTar
} else {
    Write-Host "Base tar already exists. Skipping export."
}

# ================================
# IMPORT PROD INSTANCE
# ================================
Write-Host "Creating $ProdName..."
if (!(Test-Path $ProdDir)) { New-Item -ItemType Directory -Path $ProdDir | Out-Null }
if (-not (wsl --list --quiet | Select-String "^$ProdName$")) {
    wsl --import $ProdName $ProdDir $BaseTar
} else {
    Write-Host "$ProdName already exists. Skipping import."
}

# ================================
# IMPORT TEST INSTANCE
# ================================
Write-Host "Creating $TestName..."
if (!(Test-Path $TestDir)) { New-Item -ItemType Directory -Path $TestDir | Out-Null }
if (-not (wsl --list --quiet | Select-String "^$TestName$")) {
    wsl --import $TestName $TestDir $BaseTar
} else {
    Write-Host "$TestName already exists. Skipping import."
}

# ================================
# FUNCTION: SET DEFAULT USER
# ================================
function Set-WSLDefaultUser($DistroName, $User) {
    Write-Host "Setting default user '$User' for $DistroName..."
    wsl -d $DistroName -- bash -c "echo -e '[user]\ndefault=$User' | sudo tee /etc/wsl.conf >/dev/null"
}

Set-WSLDefaultUser $ProdName $DefaultUser
Set-WSLDefaultUser $TestName $DefaultUser

# ================================
# FUNCTION: CLONE BOOTSTRAP REPO
# ================================
function Clone-BootstrapRepo($DistroName, $RepoURL, $RepoDir) {
    Write-Host "Cloning bootstrap repo into $DistroName..."

    wsl -d $DistroName -- bash -c "
        sudo apt-get update -y &&
        sudo apt-get install -y git &&
        if [ ! -d '$RepoDir/.git' ]; then
            git clone '$RepoURL' '$RepoDir'
        else
            git -C '$RepoDir' pull --ff-only
        fi
    "

    # Run bootstrap.sh if present
    wsl -d $DistroName -- bash -c "
        if [ -f '$RepoDir/bootstrap.sh' ]; then
            chmod +x '$RepoDir/bootstrap.sh'
            '$RepoDir/bootstrap.sh'
        fi
    "
}

Clone-BootstrapRepo $ProdName $RepoURL $RepoDir
Clone-BootstrapRepo $TestName $RepoURL $RepoDir

Write-Host "All done! Prod and Test WSL instances are ready."