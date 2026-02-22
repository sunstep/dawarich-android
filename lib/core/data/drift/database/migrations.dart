

import 'package:dawarich/core/data/drift/database/sqlite_client.steps.dart';
import 'package:dawarich/core/data/drift/migrations/drift_v6.dart';
import 'package:drift/drift.dart';

extension Migrations on GeneratedDatabase {

  OnUpgrade get schemaUpgrade => stepByStep(
      from5To6: migrateToV6
  );
}