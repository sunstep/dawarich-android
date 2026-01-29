# Database Migration Testing Guide

This guide explains how to test database migrations using Drift's built-in testing framework.

## Overview

We use Drift's `SchemaVerifier` to ensure database migrations work correctly. This catches migration issues **before** they reach users.

## Setup

The migration tests are located in:
- `test/core/database/drift/schema_verification_test.dart`

Schema snapshots are stored in:
- `drift_schemas/` directory (created when you generate schemas)

## Generating Schema Files

**Every time you change the database schema**, you need to generate new schema snapshot files:

### On Windows:
```bash
.\generate_schemas.bat
```

### On Linux/Mac:
```bash
./generate_schemas.sh
```

Or manually:
```bash
dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/
```

This creates files like:
- `drift_schemas/drift_schema_v4.json`
- `drift_schemas/drift_schema_v5.json`
- etc.

## Running Migration Tests

```bash
flutter test test/core/database/drift/schema_verification_test.dart
```

## When to Run Tests

Run migration tests:
1. **Before releasing a new version** with schema changes
2. **After modifying any table definitions** or migrations
3. **In your CI/CD pipeline** (add to GitHub Actions)
4. **When adding new migrations** (test both old → new and verify new schema)

## What the Tests Do

### Test 1: Upgrade from v4 to v5
- Creates a database at schema version 4
- Inserts test data with old column names (`timestamp`)
- Runs the migration to version 5
- Verifies:
  - Old column (`timestamp`) is renamed to new columns
  - New columns (`record_timestamp`, `provider_timestamp`) exist
  - Data is preserved correctly
  - No data loss during migration

### Test 2: Schema v5 Matches Code
- Verifies the generated schema matches what the code expects
- Ensures all columns are present
- Catches discrepancies between code and schema files

### Test 3: Can Insert and Query Data
- Verifies the v5 schema is functional
- Tests basic CRUD operations work correctly

## Adding New Migration Tests

When you add a new schema version (e.g., v6), add a new test:

```dart
test('upgrade from v5 to v6 works', () async {
  final connection = await verifier.startAt(5);
  final db = SQLiteClient._(connection);
  
  // Insert test data in v5 format
  await db.customStatement('INSERT INTO ...');
  
  await db.close();
  
  // Migrate to v6
  final migratedConnection = await verifier.migrateAndValidate(db, 6);
  final migratedDb = SQLiteClient._(migratedConnection);
  
  // Verify v6 schema and data
  // ...
  
  await migratedDb.close();
});
```

## CI/CD Integration

Add to `.github/workflows/test.yml`:

```yaml
- name: Generate schema files
  run: dart run drift_dev schema dump lib/core/database/drift/database/sqlite_client.dart drift_schemas/

- name: Run migration tests
  run: flutter test test/core/database/drift/schema_verification_test.dart
```

## Troubleshooting

### "Schema file not found"
- Run `generate_schemas.bat` to create schema snapshot files
- Commit the `drift_schemas/` directory to your repository

### "Migration test fails"
- Check the error message for which assertion failed
- Verify your migration logic in `sqlite_client.dart`
- Ensure schema files are up-to-date
- Test manually by creating a v4 database and upgrading

### "Column not found" errors
- Your migration might not be renaming/adding columns correctly
- Check the `onUpgrade` method in `sqlite_client.dart`
- The recovery logic in `beforeOpen` is a safety net, but migrations should work without it

## Best Practices

1. **Always generate schema files** after changing table definitions
2. **Run tests before committing** schema changes
3. **Test all migration paths** (v1→v2, v2→v3, etc.)
4. **Keep schema files in version control** - they're essential for testing
5. **Write descriptive test names** that explain what's being tested
6. **Add data preservation tests** to verify no data is lost during migrations

## Recovery Logic

The `beforeOpen` hook contains recovery logic that fixes incomplete migrations from older app versions. This is a **legacy safety net** for users who already have broken databases from when the migration system was less robust.

**Important:** With the current migration system using raw SQL, new migrations should work correctly without recovery. The recovery logic can be removed in a future version after all users have upgraded past v5.

## Example Workflow

When releasing a new version with database changes:

1. Update schema (e.g., add new table/column)
2. Update `schemaVersion` constant
3. Add migration logic in `onUpgrade`
4. Run `generate_schemas.bat`
5. Add tests for the new migration
6. Run `flutter test test/core/database/drift/schema_verification_test.dart`
7. Fix any issues
8. Commit changes including `drift_schemas/` directory
9. Release with confidence! 🚀
