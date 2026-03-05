<#  Clone-WSL-Distro.ps1
    WSL2 distro duplication on Windows 11 (robust: uses --list --quiet for name checks)

    Examples:
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "test-copy"
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "U24-lab" -InstallRoot "C:\WSL" -BackupRoot "C:\WSL\_exports"
      .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "U24-test" -DefaultUser "gebeIea" -SetDefaultDistro -KeepTar
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Source,

  [Parameter(Mandatory = $true)]
  [string]$Clone,

  # Where the clone will live (WSL stores the ext4.vhdx under here)
  [string]$InstallRoot = "C:\WSL",

  # Where the exported tar will be written
  [string]$BackupRoot  = "C:\WSL\_exports",

  # Optional: set default Linux user in the cloned distro (must already exist inside the distro)
  [string]$DefaultUser = "",

  # Optional: make the clone the default distro after import
  [switch]$SetDefaultDistro,

  # Keep the tar archive after import (default is to delete it)
  [switch]$KeepTar
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail($msg) { throw "[Clone-WSL-Distro] $msg" }

# --- Preflight: ensure wsl exists ---
$wsl = (Get-Command wsl.exe -ErrorAction Stop).Source

function Run-Wsl([string[]]$Args) {
  & $wsl @Args
  if ($LASTEXITCODE -ne 0) {
    Fail ("wsl.exe failed (exit {0}) running: wsl {1}" -f $LASTEXITCODE, ($Args -join " "))
  }
}

# --- Logging ---
$logDir = Join-Path $InstallRoot "_logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir ("Clone-WSL_{0}.log" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
Start-Transcript -Path $logFile -Append | Out-Null

try {
  # --- Get distro names via --quiet (machine-friendly) ---
  $namesRaw = & $wsl --list --quiet
  if ($LASTEXITCODE -ne 0) { Fail "wsl --list --quiet failed (exit $LASTEXITCODE)" }

  # Normalize names (trim, drop empties)
  $names = @($namesRaw | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })

  Write-Host ("Available WSL distros({0}): {1}" -f $names.Count, ($names -join ", "))

  if ($names -notcontains $Source) {
    Fail "Source distro '$Source' not found. Run: wsl -l -q"
  }
  if ($names -contains $Clone) {
    Fail "Clone distro name '$Clone' already exists. Choose a different name or unregister it: wsl --unregister `"$Clone`""
  }

  # --- Verify source looks like WSL2 (lightweight sanity check) ---
  # WSL2 runs a real Linux kernel; /proc/version typically contains "microsoft"
  $procVersion = & $wsl --distribution $Source --exec sh -lc "cat /proc/version 2>/dev/null || true"
  if ($LASTEXITCODE -ne 0) { Fail "Unable to run commands in source distro '$Source'. Is it broken?" }

  if ($procVersion -notmatch 'microsoft') {
    Fail ("Source distro '$Source' does not appear to be running on the WSL2 kernel. " +
          "This script is intended for WSL2 duplication.")
  }

  # --- Build paths ---
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $backupDir  = Join-Path $BackupRoot  $Source
  $installDir = Join-Path $InstallRoot $Clone
  $tarPath    = Join-Path $backupDir  "$Source-$stamp.tar"

  # --- Create folders ---
  New-Item -ItemType Directory -Force -Path $backupDir  | Out-Null
  New-Item -ItemType Directory -Force -Path $installDir | Out-Null

  # --- Preflight: verify we can write to the export location ---
  $probeFile = Join-Path $backupDir ("_write_test_{0}.tmp" -f $stamp)
  try {
    "probe" | Set-Content -LiteralPath $probeFile -Encoding ASCII -Force
    Remove-Item -LiteralPath $probeFile -Force
  } catch {
    Fail ("Cannot write to '{0}' as Windows user '{1}'. " +
          "Even if NTFS ACLs look right, security tooling (e.g., Controlled Folder Access) can block writes. " +
          "Pick a different BackupRoot or allow-list wsl.exe." -f $backupDir, $env:USERNAME)
  }

  Write-Host "Source:     $Source"
  Write-Host "Clone:      $Clone"
  Write-Host "Export tar: $tarPath"
  Write-Host "Install to: $installDir"
  Write-Host ""

  # --- Make export consistent: shut down WSL ---
  Write-Host "Stopping WSL (wsl --shutdown) ..."
  Run-Wsl @("--shutdown")

  # --- Export ---
  Write-Host "Exporting '$Source' ..."
  Run-Wsl @("--export", $Source, $tarPath)

  if (-not (Test-Path -LiteralPath $tarPath)) {
    Fail "Export failed; tar was not created: $tarPath"
  }

  # --- Import ---
  Write-Host "Importing as '$Clone' ..."
  Run-Wsl @("--import", $Clone, $installDir, $tarPath)

  # --- Optional: set default user for clone via /etc/wsl.conf ---
  if ($DefaultUser.Trim() -ne "") {
    Write-Host "Setting default user for '$Clone' to '$DefaultUser' ..."

    # Validate user exists inside the clone, then set /etc/wsl.conf
    Run-Wsl @("--distribution", $Clone, "--user", "root", "--exec", "sh", "-lc", "id -u '$DefaultUser' >/dev/null 2>&1")
    Run-Wsl @("--distribution", $Clone, "--user", "root", "--exec", "sh", "-lc", "printf '[user]\ndefault=%s\n' '$DefaultUser' > /etc/wsl.conf")
  }

  # --- Optional: set clone as default distro ---
  if ($SetDefaultDistro) {
    Write-Host "Setting '$Clone' as the default distro ..."
    Run-Wsl @("--set-default", $Clone)
  }

  # --- Post-check (quiet list for existence) ---
  $namesAfter = @((& $wsl --list --quiet) | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" })
  if ($namesAfter -notcontains $Clone) {
    Fail "Import appeared to succeed, but clone '$Clone' is not listed in: wsl -l -q"
  }

  Write-Host ""
  Write-Host "Success. Current distros: $($namesAfter -join ', ')"

  # --- Cleanup tar ---
  if (-not $KeepTar) {
    Write-Host ""
    Write-Host "Deleting export tar (use -KeepTar to preserve it) ..."
    Remove-Item -LiteralPath $tarPath -Force
  }

  Write-Host ""
  Write-Host "Done. Launch the clone with:"
  Write-Host "  wsl -d `"$Clone`""
  Write-Host "Log saved to: $logFile"
}
finally {
  Stop-Transcript | Out-Null
}
