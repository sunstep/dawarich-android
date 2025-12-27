
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:session_box/session_box.dart';


final class SetAutomaticTrackingSettingUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  SetAutomaticTrackingSettingUseCase(this._trackerSettingsRepository, this._userSession);

  Future<void> call(bool trueOrFalse) async {
    final int userId = await _requireUserId();

    _trackerSettingsRepository.setAutomaticTrackingSetting(
        userId, trueOrFalse);
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