@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "PROJECT_ROOT=%%~fI"
set "PS_SCRIPT=%SCRIPT_DIR%generate-lockfiles.ps1"

pushd "%PROJECT_ROOT%"

where pwsh >nul 2>nul
if %errorlevel%==0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -ProjectRoot "%PROJECT_ROOT%"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%" -ProjectRoot "%PROJECT_ROOT%"
)

set "EXITCODE=%errorlevel%"
popd

if not "%EXITCODE%"=="0" (
  echo.
  echo [ERROR] Failed with exit code %EXITCODE%
  pause
  exit /b %EXITCODE%
)

echo.
echo [OK] Lockfiles generated.
pause
exit /b 0