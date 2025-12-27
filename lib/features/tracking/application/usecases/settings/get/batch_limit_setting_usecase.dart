

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';

final class GetBatchLimitSettingUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  GetBatchLimitSettingUseCase(this._trackerSettingsRepository, this._userSession);

  Future<int> call() async {
    final int userId = await _requireUserId();
    final Option<int> result =
    await _trackerSettingsRepository.getPointsPerBatchSetting(userId);

    return result.isSome() ? result.unwrap() : 50;
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