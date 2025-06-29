import 'package:dawarich/core/database/drift/database/sqlite_client.dart';

final class DriftHelper {
  final SQLiteClient _driftDb;
  DriftHelper(this._driftDb);

  /// Returns a map of table names (for clarity) to their row counts.
  /// For example: { "points": 42, "geometry": 42, "properties": 42, "tracks": 5, "users": 1 }
  Future<Map<String, int>> countAllOldTables() async {
    final Map<String, int> counts = {};

    counts['points'] =
        (await _driftDb.select(_driftDb.pointsTable).get()).length;
    counts['geometry'] =
        (await _driftDb.select(_driftDb.pointGeometryTable).get()).length;
    counts['properties'] =
        (await _driftDb.select(_driftDb.pointPropertiesTable).get()).length;
    counts['tracks'] =
        (await _driftDb.select(_driftDb.trackTable).get()).length;
    counts['users'] = (await _driftDb.select(_driftDb.userTable).get()).length;

    return counts;
  }

  /// Returns true if at least one of the old Drift tables has > 0 rows.
  Future<bool> hasAnyRows() async {
    final Map<String, int> counts = await countAllOldTables();
    final int total = counts.values.fold<int>(0, (sum, c) => sum + c);
    return total > 0;
  }
}
