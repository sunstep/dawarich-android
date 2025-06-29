import 'package:dawarich/core/database/drift/extensions/mappers/track_mapper.dart';
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/track/track_dto.dart';
import 'package:dawarich/data_contracts/interfaces/track_repository.dart';
import 'package:drift/drift.dart';
import 'package:option_result/option.dart';

@Deprecated('Use objectbox instead')
final class DriftTrackRepository implements ITrackRepository {
  final SQLiteClient _database;
  DriftTrackRepository(this._database);

  @override
  @Deprecated('Drift DAL is no longer in use, look at ObjectBox DAL for actual functionality.')
  Future<int> storeTrack(TrackDto track) async {
    return _database.into(_database.trackTable).insert(TrackTableCompanion(
        trackId: Value(track.trackId),
        startTimestamp: Value(track.startTime),
        endTimestamp: Value(track.endTime),
        active: Value(track.active),
        userId: Value(track.userId)));
  }

  @override
  @Deprecated('Drift DAL is no longer in use, look at ObjectBox DAL for actual functionality.')
  Future<Option<TrackDto>> getActiveTrack(int userId) async {
    final query = _database.select(_database.trackTable)
      ..where((t) => t.userId.equals(userId) & t.active.equals(true))
      ..limit(1);

    final TrackTableData? result = await query.getSingleOrNull();

    if (result != null) {
      TrackDto track = result.fromDatabase();
      return Some(track);
    }

    return const None();
  }

  @override
  @Deprecated('Drift DAL is no longer in use, look at ObjectBox DAL for actual functionality.')
  Future<bool> stopTrack(TrackDto track) async {
    final int rowsAffected = await (_database.update(_database.trackTable)
          ..where((t) => t.trackId.equals(track.trackId)))
        .write(TrackTableCompanion(
            active: const Value(false), endTimestamp: Value(track.endTime)));

    return rowsAffected == 1;
  }
}
