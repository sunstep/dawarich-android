

import 'package:dawarich/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data/objectbox/entities/point/point_properties_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:option_result/option_result.dart';

final class MigratePointProperties {

  final SQLiteClient _driftDb;
  final Store _obxDb;
  MigratePointProperties(this._driftDb, this._obxDb);

  Future<Result<(), String>> startMigration() async {

    final allDriftRows = await _driftDb.select(_driftDb.pointPropertiesTable).get();
    final int driftRowCount = allDriftRows.length;

    if (driftRowCount == 0) {
      return Err("[DriftToObjectbox] Point properties migration was not necessary due to empty Drift table");
    }

    final Box<PointPropertiesEntity> pointPropertiesBox = _obxDb.box<PointPropertiesEntity>();

    if (pointPropertiesBox.count() == driftRowCount) {
      return Err("[DriftToObjectbox] Point properties migration was not necessary due to the obx database having the same data as ");
    }

    final List<PointPropertiesEntity> migratedTable = allDriftRows.map((row) {
      return PointPropertiesEntity(
        id: row.id,
        batteryState: row.batteryState,
        batteryLevel: row.batteryLevel,
        wifi: row.wifi,
        timestamp: row.timestamp,
        altitude: row.altitude,
        speed: row.speed,
        horizontalAccuracy: row.horizontalAccuracy,
        verticalAccuracy: row.verticalAccuracy,
        speedAccuracy: row.speedAccuracy,
        course: row.course,
        courseAccuracy: row.courseAccuracy,
        trackId: row.trackId,
        deviceId: row.deviceId
      );
    }).toList();

    pointPropertiesBox.putMany(migratedTable);

    final int obxCount = pointPropertiesBox.count();

    if (obxCount != driftRowCount) {
      return Err(
        "[DriftToObjectbox] Point properties migration mismatch: Drift=$driftRowCount, ObjectBox=$obxCount",
      );
    }


    return Ok(());
  }



}