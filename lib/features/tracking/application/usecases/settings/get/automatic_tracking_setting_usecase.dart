

import 'package:dawarich/core/helpers/require_user_id.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:option_result/option.dart';

final class GetAutomaticTrackingSettingUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final RequireUserId _requireUserId;
  GetAutomaticTrackingSettingUseCase(this._trackerSettingsRepository, this._requireUserId);

  Future<bool> getAutomaticTrackingSetting() async {
    final int userId = await _requireUserId();

    final Option<bool> result = await _trackerSettingsRepository
        .getAutomaticTrackingSetting(userId);

    return result.isSome() ? result.unwrap() : false;
  }

}