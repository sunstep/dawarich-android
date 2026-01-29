#!/bin/bash

# Script to generate Drift schema files for migration testing
# These files are used by drift_dev to verify migrations work correctly

echo "Generating Drift schema files..."

# Generate schema files
dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/

if [ $? -eq 0 ]; then
    echo "✅ Schema files generated successfully in drift_schemas/"
    echo ""
    echo "Generated files:"
    ls -lh drift_schemas/
else
    echo "❌ Failed to generate schema files"
    exit 1
fi
