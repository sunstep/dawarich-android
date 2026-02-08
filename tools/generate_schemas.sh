#!/bin/bash
set -euo pipefail

echo "Running Drift migration tooling..."

# 1) Generate schema snapshots + steps + tests
dart run drift_dev make-migrations
echo "✅ Migrations generated / updated."

# 2) Run only generated migration tests
echo "Running generated migration tests..."
dart test test/drift/app/generated
echo "✅ Migration tests passed."

# Optional: print generated schema files (nice for CI logs)
if [ -d "drift_schemas" ]; then
  echo ""
  echo "Generated schema files:"
  ls -lh drift_schemas/
fi