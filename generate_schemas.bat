@echo off
REM Script to generate Drift schema files for migration testing (Windows)
REM These files are used by drift_dev to verify migrations work correctly

echo Generating Drift schema files...

dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/

if %ERRORLEVEL% EQU 0 (
    echo ✅ Schema files generated successfully in drift_schemas/
    echo.
    echo Generated files:
    dir drift_schemas\
) else (
    echo ❌ Failed to generate schema files
    exit /b 1
)
