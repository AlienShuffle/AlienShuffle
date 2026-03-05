<#  Clone-WSL-Distro.ps1  (PowerShell 7+)

    - Uses wsl --list --quiet and wsl --list --running --quiet. [1](https://github.com/microsoft/WSL/issues/4920)
    - Terminates ONLY the source distro if it is running (wsl --terminate). [2](https://wiki.debian.org/InstallingDebianOn/Microsoft/Windows/SubsystemForLinux)
    - Guardrail: never calls wsl.exe with empty args.
    - Supports built-in -WhatIf (ShouldProcess)
    - Optional -DryRun switch (same effect as -WhatIf for mutating actions, but no alias conflicts)
    - Avoids ForEach-Object Trim (which emits WhatIf messages and can skip work)
    - Forces WSL output to UTF-8 with WSL_UTF8=1 to avoid UTF-16LE/NUL parsing issues. [3](https://stackoverflow.com/questions/64633727/how-to-fix-running-scripts-is-disabled-on-this-system)[4](https://lazyadmin.nl/powershell/running-scripts-is-disabled-on-this-system/)

Examples:
      pwsh .\Clone-WSL-Distro.ps1 -Source "Ubuntu-24.04" -Clone "test-copy"
      pwsh .\Clone-WSL-Distro.ps1 -Source "Ubuntu" -Clone "test-copy" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
  [Parameter(Mandatory)]
  [string]$Source,

  [Parameter(Mandatory)]
  [string]$Clone,

  [string]$InstallRoot = "C:\WSL",
  [string]$BackupRoot  = "C:\WSL\_exports",

  [string]$DefaultUser = "",
  [switch]$SetDefaultDistro,
  [switch]$KeepTar,

  # Your preferred spelling; we implement it without aliasing to WhatIf.
  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$msg) { throw "[Clone-WSL-Distro] $msg" }

# Treat -DryRun the same as -WhatIf for *mutating* operations.
$script:Simulate = $DryRun -or $WhatIfPreference

# Don’t run from inside WSL
if ($env:WSL_DISTRO_NAME) {
  Fail "Run from Windows PowerShell 7 (pwsh) with a PS C:\... prompt, not inside WSL (WSL_DISTRO_NAME=$env:WSL_DISTRO_NAME)."
}

$wsl = (Get-Command wsl.exe -ErrorAction Stop).Source

# Force UTF-8 from wsl.exe to avoid UTF-16LE/NUL issues when parsing list output. [3](https://stackoverflow.com/questions/64633727/how-to-fix-running-scripts-is-disabled-on-this-system)[4](https://lazyadmin.nl/powershell/running-scripts-is-disabled-on-this-system/)
$prevWSL_UTF8 = $env:WSL_UTF8
$env:WSL_UTF8 = "1"

function Invoke-Wsl {
  param(
    [Parameter(Mandatory)]
    [string[]]$Args,

    [switch]$Mutating,
    [string]$ActionDescription = "WSL command"
  )

  # Guardrail: empty args would start interactive shell in default distro
  if (-not $Args -or $Args.Count -eq 0) {
    Fail "BUG: Attempted to run wsl.exe with no arguments. That would launch the default distro shell."
  }

  $cmdText = "wsl " + ($Args -join " ")

  if ($Mutating -and $script:Simulate) {
    Write-Host "[SIMULATE] WOULD RUN: $cmdText"
    return [pscustomobject]@{ ExitCode = 0; Output = @(); Skipped = $true }
  }

  if ($Mutating -and -not $PSCmdlet.ShouldProcess($ActionDescription, $cmdText)) {
    Write-Host "[WHATIF] Skipping: $cmdText"
    return [pscustomobject]@{ ExitCode = 0; Output = @(); Skipped = $true }
  }

  $out = & $wsl @Args 2>&1
  $exit = $LASTEXITCODE
  [pscustomobject]@{ ExitCode = $exit; Output = @($out); Skipped = $false }
}

function Assert-Ok($r, [string]$context, [string[]]$argsShown) {
  if ($r.ExitCode -ne 0) {
    $text = ($r.Output | ForEach-Object { $_.ToString() }) -join "`n"
    Fail "$context failed (exit $($r.ExitCode)). Command: wsl $($argsShown -join ' ')`n$text"
  }
}

function Split-And-TrimLines([string]$text) {
  # Avoid cmdlets like ForEach-Object Trim, which are affected by -WhatIf.
  $lines = @()
  foreach ($line in ($text -split "`r?`n")) {
    $t = $line.Trim()
    if ($t) { $lines += $t }
  }
  return ,$lines   # unary comma forces an array even if 0/1 elements
}

function Get-DistroNames {
  # --quiet only shows distro names. [1](https://github.com/microsoft/WSL/issues/4920)
  $r = Invoke-Wsl -Args @("--list","--quiet") -ActionDescription "List WSL distros"
  Assert-Ok $r "Listing distros" @("--list","--quiet")
  $txt = ($r.Output -join "`n")
  Split-And-TrimLines $txt
}

function Get-RunningDistroNames {
  # --running lists running distros. [1](https://github.com/microsoft/WSL/issues/4920)[2](https://wiki.debian.org/InstallingDebianOn/Microsoft/Windows/SubsystemForLinux)
  $r = Invoke-Wsl -Args @("--list","--running","--quiet") -ActionDescription "List running WSL distros"
  Assert-Ok $r "Listing running distros" @("--list","--running","--quiet")
  $txt = ($r.Output -join "`n")
  Split-And-TrimLines $txt
}

try {
  $names = Get-DistroNames
  Write-Host ("Available WSL distros({0}): {1}" -f $names.Count, ($names -join ", "))

  if ($names -notcontains $Source) { Fail "Source distro '$Source' not found. (wsl -l -q)" }
  if ($names -contains $Clone) { Fail "Clone distro '$Clone' already exists. Unregister first: wsl --unregister `"$Clone`"" }

  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $backupDir  = Join-Path $BackupRoot  $Source
  $installDir = Join-Path $InstallRoot $Clone
  $tarPath    = Join-Path $backupDir  "$Source-$stamp.tar"

  Write-Host "Source:     $Source"
  Write-Host "Clone:      $Clone"
  Write-Host "Export tar: $tarPath"
  Write-Host "Install to: $installDir"
  Write-Host ""

  if ($script:Simulate) {
    Write-Host "[SIMULATE] Would ensure dirs exist: $backupDir and $installDir"
    Write-Host "[SIMULATE] Would test write access under: $backupDir"
  } else {
    New-Item -ItemType Directory -Force -Path $backupDir  | Out-Null
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    $probe = Join-Path $backupDir "_write_test.tmp"
    "probe" | Set-Content -LiteralPath $probe -Encoding ascii -Force
    Remove-Item -LiteralPath $probe -Force
  }

  # terminate only if running
  $running = Get-RunningDistroNames
  if ($running -contains $Source) {
    Write-Host "Source '$Source' is running: terminating ONLY this distro ..."
    $r = Invoke-Wsl -Args @("--terminate",$Source) -Mutating -ActionDescription "Terminate source distro '$Source'"
    Assert-Ok $r "Terminate source distro" @("--terminate",$Source)
  } else {
    Write-Host "Source '$Source' is stopped: no termination needed."
  }

  # export
  Write-Host "Exporting '$Source' ..."
  $r = Invoke-Wsl -Args @("--export",$Source,$tarPath) -Mutating -ActionDescription "Export '$Source' to tar"
  Assert-Ok $r "Export distro" @("--export",$Source,$tarPath)

  if (-not $script:Simulate -and -not (Test-Path -LiteralPath $tarPath)) {
    Fail "Export failed; tar not found: $tarPath"
  }

  # import
  Write-Host "Importing as '$Clone' ..."
  $r = Invoke-Wsl -Args @("--import",$Clone,$installDir,$tarPath) -Mutating -ActionDescription "Import clone '$Clone'"
  Assert-Ok $r "Import distro" @("--import",$Clone,$installDir,$tarPath)

  # optional default user
  if ($DefaultUser.Trim()) {
    Write-Host "Setting default user for '$Clone' to '$DefaultUser' ..."
    $r = Invoke-Wsl -Args @("--distribution",$Clone,"--user","root","--exec","sh","-lc","id -u '$DefaultUser' >/dev/null 2>&1") -Mutating -ActionDescription "Validate default user exists"
    Assert-Ok $r "Validate DefaultUser exists" @("--distribution",$Clone,"--exec","id -u ...")

    $r = Invoke-Wsl -Args @("--distribution",$Clone,"--user","root","--exec","sh","-lc","printf '[user]\ndefault=%s\n' '$DefaultUser' > /etc/wsl.conf") -Mutating -ActionDescription "Write /etc/wsl.conf"
    Assert-Ok $r "Write /etc/wsl.conf" @("--distribution",$Clone,"--exec","printf ... > /etc/wsl.conf")
  }

  if ($SetDefaultDistro) {
    Write-Host "Setting '$Clone' as default distro ..."
    $r = Invoke-Wsl -Args @("--set-default",$Clone) -Mutating -ActionDescription "Set default distro to '$Clone'"
    Assert-Ok $r "Set default distro" @("--set-default",$Clone)
  }

  if ($script:Simulate) {
    Write-Host ""
    Write-Host "[SIMULATE] Skipping post-import validation because no changes were made."
  } else {
    $after = Get-DistroNames
    if ($after -notcontains $Clone) {
      Fail "Import appeared to succeed, but '$Clone' is not listed in: wsl -l -q"
    }
    Write-Host ""
    Write-Host "Success. Current distros: $($after -join ', ')"
  }

  if (-not $KeepTar) {
    if ($script:Simulate) {
      Write-Host "[SIMULATE] Would delete tar: $tarPath"
    } else {
      Write-Host "Deleting export tar (use -KeepTar to preserve it) ..."
      Remove-Item -LiteralPath $tarPath -Force
    }
  }

  Write-Host ""
  Write-Host "Done. Launch the clone with:"
  Write-Host "  wsl -d `"$Clone`""
}
finally {
  $env:WSL_UTF8 = $prevWSL_UTF8
}