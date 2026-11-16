param(
  [ValidateSet("setup","run")]
  [string]$Action = "run",
  [string]$Distribution = "Ubuntu"
)
$ErrorActionPreference = "Stop"
$Script = Join-Path $PSScriptRoot "kds-firmware-wsl.sh"
if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
  throw "WSL2 n'est pas disponible. Activez WSL2 et installez Ubuntu depuis Microsoft Store."
}
$LinuxScript = (& wsl.exe -d $Distribution -- wslpath -a $Script).Trim()
if ($LASTEXITCODE -ne 0 -or -not $LinuxScript) {
  throw "La distribution WSL '$Distribution' est absente. Installez Ubuntu puis relancez -Action setup."
}
Write-Host "Kds Firmware via $Distribution : $Action"
& wsl.exe -d $Distribution -- bash $LinuxScript $Action
if ($LASTEXITCODE -ne 0) {
  throw "Le backend Kds Firmware s'est arrêté avec le code $LASTEXITCODE."
}
