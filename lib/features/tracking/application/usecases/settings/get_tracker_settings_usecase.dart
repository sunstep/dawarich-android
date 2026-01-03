

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:session_box/session_box.dart';

final class GetTrackerSettingsUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  GetTrackerSettingsUseCase(this._trackerSettingsRepository, this._userSession);


  Future<TrackerSettings> call() async {
    final int userId = await _requireUserId();

    final settings = await _trackerSettingsRepository.get(userId: userId);

    return settings;
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