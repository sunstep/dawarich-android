@echo off
setlocal

REM Run from the repo root even if double-clicked
cd /d "%~dp0.."

echo ===============================
echo   Get Release Signature By Tag
echo ===============================
echo.

set "TAG="
set /p TAG=Enter the tag (example: v0.19.0): 

if "%TAG%"=="" (
    echo.
    echo No tag entered.
    echo.
    pause
    exit /b 1
)

where pwsh >nul 2>nul
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File ".\tools\Get-ReleaseSignatureByTag.ps1" -RepoPath "." -Tag "%TAG%"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\Get-ReleaseSignatureByTag.ps1" -RepoPath "." -Tag "%TAG%"
)

echo.
pause
endlocal