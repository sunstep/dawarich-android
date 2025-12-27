import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:option_result/result.dart';
import 'package:session_box/session_box.dart';


final class SetBatchLimitSettingUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  SetBatchLimitSettingUseCase(this._trackerSettingsRepository, this._userSession);

  Future<Result<(), String>> call(int amount) async {

    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setPointsPerBatchSetting(
          userId, amount);

      return Ok(());
    } catch (e) {
      return Err('Failed to update points per batch: $e');
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