

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:session_box/session_box.dart';

final class ResetDeviceIdUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  ResetDeviceIdUseCase(this._trackerSettingsRepository, this._userSession);

  Future<bool> call() async {
    final int userId = await _requireUserId();

    bool result = await _trackerSettingsRepository.deleteDeviceId(userId);

    return result;
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