[ -z "$1" ] && echo "Usage: $0 <instance-name> <clone-name>" && exit 1
[ -z "$2" ] && echo "Usage: $0 <instance-name> <clone-name>" && exit 1

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pwsh.exe \
  -File "${REPO_ROOT}/scripts/Clone-WSL-Distro.ps1" \
  -Source "$1" \
  -Clone "$2"
