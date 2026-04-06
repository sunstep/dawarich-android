@echo off
setlocal

title Drift migrations + tests

echo.
echo ===============================
echo   Drift migrations + tests
echo ===============================
echo.

REM Ensure we run from repo root (folder where this .bat is located -> go up one)
REM If your .bat is in repo root already, remove the next 2 lines.
cd /d "%~dp0"
cd /d ..

echo Repo root: %CD%
echo.

REM Check tools exist
where dart >nul 2>nul
if errorlevel 1 (
  echo ❌ "dart" not found in PATH.
  echo    If you're using Flutter, try running with "flutter pub run" or ensure Flutter\bin is on PATH.
  echo.
  pause
  exit /b 1
)

echo Running Drift migration tooling...
call dart run drift_dev make-migrations
if errorlevel 1 (
  echo.
  echo ❌ drift_dev make-migrations failed
  echo.
  pause
  exit /b 1
)

echo.
echo ✅ Migrations generated / updated.
echo.