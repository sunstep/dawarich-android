param(
  [Parameter(Mandatory=$false)]
  [string]$ProjectRoot = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Require-Cmd($name) {
  $cmd = Get-Command $name -ErrorAction SilentlyContinue
  if (-not $cmd) { throw "Required command not found: $name" }
}

function Run($exe, $args) {
  Write-Host "==> $exe $args"
  & $exe @args
  if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" }
}

# Resolve root (when called from .bat, it passes ProjectRoot)
if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
  $ProjectRoot = (Get-Location).Path
}
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
Set-Location $ProjectRoot

Require-Cmd "flutter"

$pubspecGms  = Join-Path $ProjectRoot "pubspec-gms.yaml"
$pubspecFoss = Join-Path $ProjectRoot "pubspec-foss.yaml"

if (-not (Test-Path $pubspecGms))  { throw "Missing file: $pubspecGms" }
if (-not (Test-Path $pubspecFoss)) { throw "Missing file: $pubspecFoss" }

# Use a temp swap of pubspec.yaml, then restore it safely
$pubspecMain = Join-Path $ProjectRoot "pubspec.yaml"
if (-not (Test-Path $pubspecMain)) { throw "Missing file: $pubspecMain" }

$backup = Join-Path $ProjectRoot "pubspec.yaml.bak.lockgen"

try {
  Copy-Item $pubspecMain $backup -Force

  # ---- GMS ----
  Copy-Item $pubspecGms $pubspecMain -Force
  Run "flutter" @("pub", "get")
  $lockGms = Join-Path $ProjectRoot "pubspec-gms.lock"
  Copy-Item (Join-Path $ProjectRoot "pubspec.lock") $lockGms -Force
  Write-Host "[OK] Wrote $lockGms"

  # ---- FOSS ----
  Copy-Item $pubspecFoss $pubspecMain -Force
  Run "flutter" @("pub", "get")
  $lockFoss = Join-Path $ProjectRoot "pubspec-foss.lock"
  Copy-Item (Join-Path $ProjectRoot "pubspec.lock") $lockFoss -Force
  Write-Host "[OK] Wrote $lockFoss"
}
finally {
  # Restore original pubspec.yaml
  if (Test-Path $backup) {
    Copy-Item $backup $pubspecMain -Force
    Remove-Item $backup -Force
  }
}

Write-Host "`nAll done ✅"