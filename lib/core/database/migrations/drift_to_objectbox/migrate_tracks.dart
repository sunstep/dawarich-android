import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/core/database/objectbox/entities/track/track_entity.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:option_result/result.dart';

final class MigrateTracks {
  final SQLiteClient _driftDb;
  final Store _obxDb;
  MigrateTracks(this._driftDb, this._obxDb);

  Future<Result<(), String>> startMigration() async {
    final allDriftRows = await _driftDb.select(_driftDb.trackTable).get();
    final int driftRowCount = allDriftRows.length;

    if (driftRowCount == 0) {
      return Err(
          "[DriftToObjectbox] Track migration was not necessary due to empty Drift table");
    }

    final Box<TrackEntity> trackBox = _obxDb.box<TrackEntity>();

    if (trackBox.count() == driftRowCount) {
      return Err(
          "[DriftToObjectbox] Track migration was not necessary due to the obx database having the same data as ");
    }

    final List<TrackEntity> migratedTable = allDriftRows.map((row) {
      final migratedTrack = TrackEntity(
          id: row.id,
          trackId: row.trackId,
          startTimestamp: row.startTimestamp,
          endTimestamp: row.endTimestamp,
          active: row.active);

      migratedTrack.user.targetId = row.userId;
      return migratedTrack;
    }).toList();

    trackBox.putMany(migratedTable);

    final int obxCount = trackBox.count();

    if (obxCount != driftRowCount) {
      return Err(
        "[DriftToObjectbox] Track migration mismatch: Drift=$driftRowCount, ObjectBox=$obxCount",
      );
    }

    return Ok(());
  }
}
