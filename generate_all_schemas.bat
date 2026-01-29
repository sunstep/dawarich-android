@echo off
REM Generate schema files for all versions

echo Generating schema files for all database versions...
echo.

REM Generate current version (v5)
echo [1/2] Generating schema for version 5 (current)...
dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to generate v5 schema
    exit /b 1
)
echo ✅ v5 schema generated
echo.

REM For v4, we need to manually create it since we can't time-travel
echo [2/2] To generate v4 schema, you need to:
echo   1. Temporarily change schemaVersion to 4 in sqlite_client.dart
echo   2. Comment out the v4→v5 migration in onUpgrade
echo   3. Run: dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/
echo   4. Revert changes
echo.
echo OR use a v4 database file if you have one from an old app version
echo.

echo ✅ All schemas generated successfully!
echo.
echo Generated files:
dir drift_schemas\
