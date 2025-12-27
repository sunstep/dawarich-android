import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
import 'package:option_result/option.dart';
import 'package:session_box/session_box.dart';


final class GetDeviceIdUseCase {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final IHardwareRepository _hardwareRepository;
  final SessionBox<User> _userSession;
  GetDeviceIdUseCase(this._trackerSettingsRepository, this._hardwareRepository, this._userSession);

  Future<String> call() async {
    final int userId = await _requireUserId();

    final Option<String> possibleDeviceId =
    await _trackerSettingsRepository.getDeviceId(userId);

    if (possibleDeviceId case Some(value: String deviceId)) {
      return deviceId;
    }

    final String deviceModel = await _hardwareRepository.getDeviceModel();

    return deviceModel;
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