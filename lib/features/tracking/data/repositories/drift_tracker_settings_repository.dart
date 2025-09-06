


import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:option_result/option.dart';

final class DriftTrackerSettingsRepository implements ITrackerSettingsRepository {
  final SQLiteClient _db;
  TrackerSettingsDto? _cache;

  DriftTrackerSettingsRepository(this._db);

  // ---------- Getters ----------

  @override
  Future<Option<bool>> getAutomaticTrackingSetting(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.automaticTracking != null ? Some(dto.automaticTracking!) : const None();
  }

  @override
  Future<Option<int>> getPointsPerBatchSetting(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.pointsPerBatch != null ? Some(dto.pointsPerBatch!) : const None();
  }

  @override
  Future<Option<int>> getTrackingFrequencySetting(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.trackingFrequency != null ? Some(dto.trackingFrequency!) : const None();
  }

  @override
  Future<Option<int>> getLocationAccuracySetting(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.locationAccuracy != null ? Some(dto.locationAccuracy!) : const None();
  }

  @override
  Future<Option<int>> getMinimumPointDistanceSetting(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.minimumPointDistance != null ? Some(dto.minimumPointDistance!) : const None();
  }

  @override
  Future<Option<String>> getDeviceId(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto.deviceId != null ? Some(dto.deviceId!) : const None();
  }

  // ---------- Setters ----------

  @override
  void setAutomaticTrackingSetting(int userId, bool value) {
    _update(userId, (s) => s.copyWith(automaticTracking: value));
  }

  @override
  void setPointsPerBatchSetting(int userId, int amount) {
    _update(userId, (s) => s.copyWith(pointsPerBatch: amount));
  }

  @override
  void setTrackingFrequencySetting(int userId, int seconds) {
    _update(userId, (s) => s.copyWith(trackingFrequency: seconds));
  }

  @override
  void setLocationAccuracySetting(int userId, int index) {
    _update(userId, (s) => s.copyWith(locationAccuracy: index));
  }

  @override
  void setMinimumPointDistanceSetting(int userId, int meters) {
    _update(userId, (s) => s.copyWith(minimumPointDistance: meters));
  }

  @override
  void setDeviceId(int userId, String newId) {
    _update(userId, (s) => s.copyWith(deviceId: newId));
  }

  @override
  Future<bool> deleteDeviceId(int userId) async {
    final dto = await _getOrLoad(userId);
    final updated = dto.copyWith(deviceId: null);
    _cache = updated;
    await _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(_toCompanion(updated));
    return true;
  }

  // ---------- Bulk ops ----------

  @override
  Future<Option<TrackerSettingsDto>> getTrackerSettings(int userId) async {
    final dto = await _getOrLoad(userId);
    return dto == TrackerSettingsDto.empty(userId) ? const None() : Some(dto);
  }

  @override
  void setAll(TrackerSettingsDto settings) {
    _cache = settings;
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(_toCompanion(settings));
  }

  @override
  void clearCaches(int userId) {
    if (_cache?.userId == userId) {
      _cache = null;
    }
  }

  @override
  Future<void> persistPreferences(int userId) async {
    // no-op in Drift implementation, kept for interface compatibility
    return;
  }

  // ---------- Internal helpers ----------

  Future<TrackerSettingsDto> _getOrLoad(int userId) async {
    if (_cache?.userId == userId) return _cache!;
    final row = await (_db.select(_db.trackerSettingsTable)
      ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();

    if (row == null) {
      final empty = TrackerSettingsDto.empty(userId);
      _cache = empty;
      return empty;
    }
    final dto = _fromRow(row);
    _cache = dto;
    return dto;
  }

  void _update(int userId, TrackerSettingsDto Function(TrackerSettingsDto) fn) {
    final base = _cache ?? TrackerSettingsDto.empty(userId);
    final updated = fn(base);
    _cache = updated;
    _db.into(_db.trackerSettingsTable).insertOnConflictUpdate(_toCompanion(updated));
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