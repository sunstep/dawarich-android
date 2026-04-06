import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:flutter/foundation.dart';

final class WatchTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;

  WatchTrackerSettingsUseCase(this._trackerSettingsRepository);

  Stream<TrackerSettings> call(int userId) {
    return (() async* {
      if (kDebugMode) {
        debugPrint("[WatchTrackerSettings] Starting watch for userId: $userId");
      }

      final initial = await _trackerSettingsRepository.get(userId: userId);
      if (kDebugMode) {
        debugPrint("[WatchTrackerSettings] Yielding initial: freq=${initial.trackingFrequency}s");
      }
      yield initial;

      await for (final settings in _trackerSettingsRepository
          .watch(userId: userId)
          .distinct(_equals)) {
        if (kDebugMode) {
          debugPrint("[WatchTrackerSettings] Stream emitting: freq=${settings.trackingFrequency}s");
        }
        yield settings;
      }
    })();
  }

  static bool _equals(TrackerSettings a, TrackerSettings b) {
    return a.automaticTracking == b.automaticTracking &&
        a.trackingFrequency == b.trackingFrequency &&
        a.locationPrecision == b.locationPrecision &&
        a.minimumPointDistance == b.minimumPointDistance &&
        a.pointsPerBatch == b.pointsPerBatch &&
        a.deviceId == b.deviceId;
  }

}