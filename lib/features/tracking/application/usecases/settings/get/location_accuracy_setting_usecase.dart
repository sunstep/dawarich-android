import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';



final class GetLocationAccuracySettingUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final SessionBox<User> _userSession;
  GetLocationAccuracySettingUseCase(this._trackerSettingsRepository, this._userSession);

  Future<LocationAccuracy> call() async {
    final int userId = await _requireUserId();
    final Option<int> accuracyIndex = await _trackerSettingsRepository
        .getLocationAccuracySetting(userId);

    if (accuracyIndex case Some(: final value) when value >= 0 && value < LocationAccuracy.values.length) {
      return LocationAccuracy.values[value];
    }
    return LocationAccuracy.high;

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