@echo off
setlocal

REM Run from the repo root even if double-clicked
cd /d "%~dp0.."

REM Prefer pwsh (PowerShell 7), fall back to Windows PowerShell
where pwsh >nul 2>nul
if %errorlevel%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File ".\tools\Get-LatestReleaseSignature.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\Get-LatestReleaseSignature.ps1"
)

echo.
pause
endlocal