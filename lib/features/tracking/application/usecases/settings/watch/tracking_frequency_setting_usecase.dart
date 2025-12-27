import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:session_box/session_box.dart';

final class WatchTrackingFrequencyUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  WatchTrackingFrequencyUseCase(this._trackerSettingsRepository, this._userSession);


  Future<Stream<int>> call() async {
    final int userId = await _requireUserId();
    return _trackerSettingsRepository.watchTrackingFrequencySetting(userId);
  }

  Future<int> _requireUserId() async {
    final int? userId = _userSession.getUserId();
    if (userId == null) {
      await _userSession.logout();
      throw Exception('[TrackService] No user session found.');
    }
    return userId;
  }
}