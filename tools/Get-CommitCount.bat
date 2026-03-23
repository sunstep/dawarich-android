@echo off
setlocal

:START
cls
echo ==============================
echo     Git Branch Commit Count
echo ==============================
echo.

set "BRANCH="
set /p BRANCH=Enter branch name: 

if "%BRANCH%"=="" (
    echo.
    echo No branch name entered.
    echo.
    pause
    goto START
)

git rev-parse --verify "%BRANCH%" >nul 2>&1
if errorlevel 1 (
    echo.
    echo Branch '%BRANCH%' does not exist.
    echo.
    pause
    goto START
)

for /f %%i in ('git rev-list --count "%BRANCH%"') do set "COUNT=%%i"

echo.
echo Commit count for branch '%BRANCH%': %COUNT%
echo.
pause
goto START