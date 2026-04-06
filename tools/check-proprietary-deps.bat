@echo off
setlocal
chcp 65001 >nul

pushd "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-proprietary-deps.ps1"
set EXITCODE=%ERRORLEVEL%
popd

echo.
if %EXITCODE%==0 (
  echo PASS
) else (
  echo FAIL (exit code %EXITCODE%)
)

pause
exit /b %EXITCODE%
