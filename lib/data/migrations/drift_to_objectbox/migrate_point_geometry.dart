import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data/objectbox/entities/point/point_geometry_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:option_result/option_result.dart';

final class MigratePointGeometry {
  final SQLiteClient _dritDb;
  final Store _obxDb;
  MigratePointGeometry(this._dritDb, this._obxDb);

  Future<Result<(), String>> startMigration() async {
    final allDriftRows = await _dritDb.select(_dritDb.pointGeometryTable).get();
    final int driftRowCount = allDriftRows.length;

    if (driftRowCount == 0) {
      return Err(
          "[DriftToObjectbox] Point geometry migration was not necessary due to empty Drift table");
    }

    final Box<PointGeometryEntity> pointGeometryBox =
        _obxDb.box<PointGeometryEntity>();

    if (pointGeometryBox.count() == driftRowCount) {
      return Err(
          "[DriftToObjectbox] Point geometry migration was not necessary due to the obx database having the same data as ");
    }

    final List<PointGeometryEntity> migratedTable = allDriftRows.map((row) {
      return PointGeometryEntity(
          id: row.id, type: row.type, coordinates: row.coordinates);
    }).toList();

    pointGeometryBox.putMany(migratedTable);

    final int obxCount = pointGeometryBox.count();
    if (obxCount != driftRowCount) {
      return Err(
        "[DriftToObjectbox] User migration mismatch: Drift=$driftRowCount, ObjectBox=$obxCount",
      );
    }

    return Ok(());
  }
}
