@echo off
setlocal

cd /d "%~dp0"

echo ===============================
echo   Drift: run migration tests
echo ===============================
echo.

dart test test/drift
if errorlevel 1 (
  echo.
  echo ❌ Migration tests failed
  pause
  exit /b 1
)

echo.
echo ✅ Migration tests passed.
pause
exit /b 0