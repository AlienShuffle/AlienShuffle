# need to fix the path to the powershell script and the source and clone distro names
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

powershell.exe -ExecutionPolicy Bypass \
  -File "${REPO_ROOT}/scripts-powershell/Clone-WSL2Distro.ps1" \
  -Source "Ubuntu-24.04" \
  -Clone "U24-lab"
