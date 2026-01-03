

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:session_box/session_box.dart';

final class WatchTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  WatchTrackerSettingsUseCase(this._trackerSettingsRepository, this._userSession);

  Future<Stream<TrackerSettings>> call() async {
    final int userId = await _requireUserId();

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
        a.locationAccuracy == b.locationAccuracy &&
        a.minimumPointDistance == b.minimumPointDistance &&
        a.pointsPerBatch == b.pointsPerBatch &&
        a.deviceId == b.deviceId;
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[ApiPointService] No user session found.');
    }
    return userId;
  }

}