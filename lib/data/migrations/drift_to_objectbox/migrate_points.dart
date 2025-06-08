

import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data/objectbox/entities/point/point_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:option_result/option_result.dart';

final class MigratePoints {

  final SQLiteClient _driftDb;
  final Store _obxDb;
  MigratePoints(this._driftDb, this._obxDb);

  Future<Result<(), String>> startMigration() async {

    final allDriftRows = await _driftDb.select(_driftDb.pointsTable).get();
    final int driftRowCount = allDriftRows.length;

    if (driftRowCount == 0) {
      return Err("[DriftToObjectbox] Point migration was not necessary due to empty Drift table");
    }

    final Box<PointEntity> pointBox = _obxDb.box<PointEntity>();

    if (pointBox.count() == driftRowCount) {
      return Err("[DriftToObjectbox] Point migration was not necessary due to the obx database having the same data as ");
    }

    final List<PointEntity> migratedTable = allDriftRows.map((row) {
      final migratedPoints = PointEntity(
        id: row.id,
        type: row.type,
        isUploaded: row.isUploaded
      );

      migratedPoints.geometry.targetId = row.geometryId;
      migratedPoints.properties.targetId = row.propertiesId;
      migratedPoints.user.targetId = row.userId;

      return migratedPoints;
    }).toList();

    pointBox.putMany(migratedTable);

    final int obxCount = pointBox.count();

    if (obxCount != driftRowCount) {
      return Err(
        "[DriftToObjectbox] Point migration mismatch: Drift=$driftRowCount, ObjectBox=$obxCount",
      );
    }


    return Ok(());
  }


}