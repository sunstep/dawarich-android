import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:option_result/result.dart';
import 'package:session_box/session_box.dart';

final class SetDeviceIdUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  SetDeviceIdUseCase(this._trackerSettingsRepository, this._userSession);

  Future<Result<(), String>> call(String newId) async {
    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setDeviceId(userId, newId);

      return Ok(());
    } catch (e) {
      return Err('Failed to update device ID: $e');
    }

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