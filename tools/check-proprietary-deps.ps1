Param(
  [string]$AndroidDir = "android",
  [string[]]$Configurations = @("gmsReleaseRuntimeClasspath", "fossReleaseRuntimeClasspath"),
  [string[]]$Patterns = @(
    "com.google.android.gms",
    "com.google.firebase",
    "com.google.mlkit",
    "com.google.android.play",
    "crashlytics",
    "firebase"
  )
)

$ErrorActionPreference = "Stop"

# Resolve android dir relative to repo root (assumes script is in /tools)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..")
$AndroidPath = Resolve-Path (Join-Path $RepoRoot $AndroidDir)

function Invoke-GradleDeps([string]$config) {
  Push-Location $AndroidPath
  try {
    $cmd = ".\gradlew :app:dependencies --configuration $config"
    Write-Host "==> $cmd" -ForegroundColor Cyan
    $output = Invoke-Expression $cmd
    return $output
  } finally {
    Pop-Location
  }
}

function Find-Matches([string[]]$lines, [string[]]$patterns) {
  $matches = @()
  foreach ($p in $patterns) {
    $hits = $lines | Select-String -Pattern $p -SimpleMatch
    if ($hits) {
      $matches += $hits
    }
  }
  return $matches
}

$failed = $false

foreach ($config in $Configurations) {
  Write-Host ""
  Write-Host "------------------------------" -ForegroundColor DarkGray
  Write-Host "Checking: $config" -ForegroundColor Yellow
  Write-Host "------------------------------" -ForegroundColor DarkGray

  $depsText = Invoke-GradleDeps $config
  $lines = $depsText -split "`r?`n"

  $hits = Find-Matches $lines $Patterns

  if ($hits.Count -eq 0) {
    Write-Host "No matches found."
    continue
  }

  Write-Host "Matches found:" -ForegroundColor Red
  $hits | ForEach-Object { Write-Host $_.Line }

  if ($config.ToLower().Contains("foss")) {
    $failed = $true
  }
}

Write-Host ""
if ($failed) {
  Write-Host "FAIL: FOSS configuration contains proprietary-looking dependencies." -ForegroundColor Red
  exit 1
}

Write-Host "PASS: No proprietary-looking dependencies found in FOSS configuration." -ForegroundColor Green
exit 0
