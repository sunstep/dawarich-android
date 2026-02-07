import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';

final class WatchTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;

  WatchTrackerSettingsUseCase(this._trackerSettingsRepository);

  Stream<TrackerSettings> call(int userId) {
    return (() async* {
      final initial = await _trackerSettingsRepository.get(userId: userId);
      yield initial;

      yield* _trackerSettingsRepository
          .watch(userId: userId)
          .distinct(_equals);
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