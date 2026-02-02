@echo off
setlocal enabledelayedexpansion

echo Running Drift migration tooling...

dart run drift_dev make-migrations
if %ERRORLEVEL% NEQ 0 (
  echo ❌ drift_dev make-migrations failed
  exit /b 1
)

echo ✅ Migrations generated / updated.

echo Running generated migration tests...
dart test test/drift/app/generated
if %ERRORLEVEL% NEQ 0 (
  echo ❌ Migration tests failed
  exit /b 1
)

echo ✅ Migration tests passed.
exit /b 0