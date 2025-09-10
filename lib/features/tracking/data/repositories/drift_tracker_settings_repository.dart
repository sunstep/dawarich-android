


import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:option_result/option.dart';

final class DriftTrackerSettingsRepository implements ITrackerSettingsRepository {

  final SQLiteClient _db;
  DriftTrackerSettingsRepository(this._db);

  // ---------- Getters ----------

  @override
  Future<Option<bool>> getAutomaticTrackingSetting(int userId) async {
    final row = await _readRow(userId);
    final v = row?.automaticTracking;
    return v == null ? const None() : Some(v);
  }

  @override
  Future<Option<int>> getPointsPerBatchSetting(int userId) async {
    final row = await _readRow(userId);
    final v = row?.pointsPerBatch;
    return v == null ? const None() : Some(v);
  }

  @override
  Future<Option<int>> getTrackingFrequencySetting(int userId) async {
    final row = await _readRow(userId);
    final v = row?.trackingFrequency;
    return v == null ? const None() : Some(v);
  }

  @override
  Future<Option<int>> getLocationAccuracySetting(int userId) async {
    final row = await _readRow(userId);
    final v = row?.locationAccuracy;
    return v == null ? const None() : Some(v);
  }

  @override
  Future<Option<int>> getMinimumPointDistanceSetting(int userId) async {
    final row = await _readRow(userId);
    final v = row?.minimumPointDistance;
    return v == null ? const None() : Some(v);
  }

  @override
  Future<Option<String>> getDeviceId(int userId) async {
    final row = await _readRow(userId);
    final v = row?.deviceId;
    return v == null ? const None() : Some(v);
  }


  // ---------- Streams ----------

  @override
  Stream<int> watchTrackingFrequencySetting(int userId) {
    final q = (_db.select(_db.trackerSettingsTable)
      ..where((t) => t.userId.equals(userId)));

    return q
        .watchSingleOrNull()                 // Stream<TrackerSettingsTableData?>
        .map((row) => row?.trackingFrequency) // Stream<int?>
        .where((v) => v != null)              // filter nulls
        .map((v) => v!)                        // cast to int
        .distinct();                           // avoid duplicates
  }

  // ---------- Setters ----------

  @override
  void setAutomaticTrackingSetting(int userId, bool value) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        automaticTracking: Value(value),
      ),
    );
  }

  @override
  void setPointsPerBatchSetting(int userId, int amount) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        pointsPerBatch: Value(amount),
      ),
    );
  }

  @override
  void setTrackingFrequencySetting(int userId, int seconds) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        trackingFrequency: Value(seconds),
      ),
    );
  }

  @override
  void setLocationAccuracySetting(int userId, int index) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        locationAccuracy: Value(index),
      ),
    );
  }

  @override
  void setMinimumPointDistanceSetting(int userId, int meters) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        minimumPointDistance: Value(meters),
      ),
    );
  }

  @override
  void setDeviceId(int userId, String newId) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        deviceId: Value(newId),
      ),
    );
  }

  @override
  Future<bool> deleteDeviceId(int userId) async {
    // For nullable columns, pass Value(null) to clear
    await _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(
      TrackerSettingsTableCompanion(
        userId: Value(userId),
        deviceId: const Value(null),
      ),
    );
    return true;
  }

  // ---------- Bulk ops ----------

  @override
  Future<Option<TrackerSettingsDto>> getTrackerSettings(int userId) async {
    final row = await _readRow(userId);
    if (row == null) return const None();
    final dto = _fromRow(row);
    return dto == TrackerSettingsDto.empty(userId) ? const None() : Some(dto);
  }

  @override
  void setAll(TrackerSettingsDto settings) {
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(_toCompanion(settings));
  }



  // ---------- Internal helpers ----------

  Future<TrackerSettingsTableData?> _readRow(int userId) {
    return (_db.select(_db.trackerSettingsTable)
      ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  TrackerSettingsDto _fromRow(TrackerSettingsTableData r) => TrackerSettingsDto(
    userId: r.userId,
    automaticTracking: r.automaticTracking,
    trackingFrequency: r.trackingFrequency,
    locationAccuracy: r.locationAccuracy,
    minimumPointDistance: r.minimumPointDistance,
    pointsPerBatch: r.pointsPerBatch,
    deviceId: r.deviceId,
  );

  TrackerSettingsTableCompanion _toCompanion(TrackerSettingsDto s) =>
      TrackerSettingsTableCompanion(
        userId: Value(s.userId),
        automaticTracking: Value(s.automaticTracking),
        trackingFrequency: Value(s.trackingFrequency),
        locationAccuracy: Value(s.locationAccuracy),
        minimumPointDistance: Value(s.minimumPointDistance),
        pointsPerBatch: Value(s.pointsPerBatch),
        deviceId: Value(s.deviceId),
      );
}