<#  Clone-WSL-Distro.ps1
    Bulletproof WSL2 distro duplication on Windows 11.

    Examples:
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "Ubuntu-24.04-copy"
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "U24-lab" -InstallRoot "D:\WSL" -BackupRoot "D:\WSL\_exports"
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "U24-test" -DefaultUser "gebeIea" -SetDefaultDistro
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Source,

  [Parameter(Mandatory=$true)]
  [string]$Clone,

  # Where the clone will live (WSL stores the ext4.vhdx under here)
  [string]$InstallRoot = "C:\WSL",

  # Where the exported tar will be written (must be writable by your Windows user)
  [string]$BackupRoot  = "C:\WSL\WSL-Exports",

  # Optional: set a default Linux user in the cloned distro (requires that user already exists inside the distro)
  [string]$DefaultUser,

  # Optional: make the clone the default distro after import
  [switch]$SetDefaultDistro,

  # Keep the tar archive after import (default is to delete it)
  [switch]$KeepTar
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail($msg) { throw "[Clone-WSL2] $msg" }

# --- Preflight: ensure wsl exists ---
$wsl = (Get-Command wsl.exe -ErrorAction Stop).Source

# --- Preflight: list distros and validate source exists ---
$raw = & $wsl --list --verbose
if (-not $raw) { Fail "No WSL distributions found." }

# Parse "wsl -l -v" output
# NAME                   STATE           VERSION
# * Ubuntu-24.04          Running         2
$lines = $raw | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne "" }
$distroInfo = @{}
foreach ($ln in $lines) {
  $clean = $ln.TrimStart()
  $isDefault = $clean.StartsWith("*")
  if ($isDefault) { $clean = $clean.TrimStart("*").TrimStart() }

  # Split by 2+ spaces
  $parts = $clean -split "\s{2,}"
  if ($parts.Count -ge 3) {
    $name = $parts[0].Trim()
    $state = $parts[1].Trim()
    $ver = $parts[2].Trim()
    $distroInfo[$name] = [pscustomobject]@{ Name=$name; State=$state; Version=$ver; Default=$isDefault }
  }
}

if (-not $distroInfo.ContainsKey($Source)) {
  Fail "Source distro '$Source' not found. Run: wsl -l -v"
}
if ($distroInfo[$Source].Version -ne "2") {
  Fail "Source distro '$Source' is not WSL2 (VERSION != 2). Convert it first: wsl --set-version `"$Source`" 2"
}

# --- Refuse to overwrite clone name ---
if ($distroInfo.ContainsKey($Clone)) {
  Fail "Clone distro name '$Clone' already exists. Choose a different name or unregister it: wsl --unregister `"$Clone`""
}

# --- Build paths ---
# Use timestamp to avoid collisions and to make repeated runs safe
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir  = Join-Path $BackupRoot  $Source
$installDir = Join-Path $InstallRoot $Clone
$tarPath    = Join-Path $backupDir  "$Source-$stamp.tar"

# --- Create folders (ensures Windows ACLs are sane under your profile) ---
New-Item -ItemType Directory -Force -Path $backupDir  | Out-Null
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

Write-Host "Source:     $Source (WSL$($distroInfo[$Source].Version), State=$($distroInfo[$Source].State))"
Write-Host "Clone:      $Clone"
Write-Host "Export tar: $tarPath"
Write-Host "Install to: $installDir"
Write-Host ""

# --- Make export consistent: shut down WSL ---
Write-Host "Stopping WSL (wsl --shutdown) ..."
& $wsl --shutdown

# --- Export ---
Write-Host "Exporting '$Source' ..."
& $wsl --export $Source $tarPath

if (-not (Test-Path $tarPath)) {
  Fail "Export failed; tar was not created: $tarPath"
}

# --- Import ---
Write-Host "Importing as '$Clone' ..."
& $wsl --import $Clone $installDir $tarPath

# --- Optional: set default user for clone ---
if ($DefaultUser -and $DefaultUser.Trim() -ne "") {
  Write-Host "Setting default user for '$Clone' to '$DefaultUser' ..."
  # This requires WSL supports config --default-user. If unavailable, user can do it via /etc/wsl.conf
  try {
    & $wsl --distribution $Clone --user root --exec sh -lc "id -u '$DefaultUser' >/dev/null 2>&1" | Out-Null
    & $wsl --distribution $Clone --user root --exec sh -lc "printf '[user]\ndefault=%s\n' '$DefaultUser' > /etc/wsl.conf"
  } catch {
    Fail "Could not set default user. Ensure '$DefaultUser' exists in the clone. You can create it inside the distro or remove -DefaultUser."
  }
}

# --- Optional: set clone as default distro ---
if ($SetDefaultDistro) {
  Write-Host "Setting '$Clone' as the default distro ..."
  & $wsl --set-default $Clone
}

# --- Post-check ---
Write-Host ""
Write-Host "Verifying ..."
& $wsl --list --verbose

# --- Cleanup tar ---
if (-not $KeepTar) {
  Write-Host ""
  Write-Host "Deleting export tar (use -KeepTar to preserve it) ..."
  Remove-Item -Force $tarPath
}

Write-Host ""
Write-Host "Done. Launch the clone with:"
Write-Host "  wsl -d `"$Clone`""