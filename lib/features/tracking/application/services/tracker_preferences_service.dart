import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:dawarich/core/session/domain/legacy_user_session_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:user_session_manager/user_session_manager.dart';

class TrackerPreferencesService {
  final ITrackerPreferencesRepository _trackerPreferencesRepository;
  final IHardwareRepository _hardwareRepository;
  final UserSessionManager<int> _user;
  TrackerPreferencesService(
      this._trackerPreferencesRepository, this._hardwareRepository, this._user);

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {
    final int? userId = await _user.getUser();

    if (userId == null) {
      return;
    }

    await _trackerPreferencesRepository.setAutomaticTrackingPreference(
        userId, trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return;
    }
    await _trackerPreferencesRepository.setPointsPerBatchPreference(
        userId, amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return;
    }
    await _trackerPreferencesRepository.setTrackingFrequencyPreference(
        userId, seconds);
  }

  Future<void> setLocationAccuracyPreference(LocationAccuracy accuracy) async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return;
    }
    await _trackerPreferencesRepository.setLocationAccuracyPreference(
        userId, accuracy.index);
  }

  Future<void> setMinimumPointDistancePreference(int meters) async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return;
    }
    await _trackerPreferencesRepository.setMinimumPointDistancePreference(
        userId, meters);
  }

  Future<void> setTrackerId(String newId) async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return;
    }
    await _trackerPreferencesRepository.setTrackerId(userId, newId);
  }

  Future<bool> resetTrackerId() async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return false;
    }
    return await _trackerPreferencesRepository.deleteTrackerId(userId);
  }

  Future<bool> getAutomaticTrackingPreference() async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return false;
    }
    final Option<bool> result = await _trackerPreferencesRepository
        .getAutomaticTrackingPreference(userId);

    return result.isSome() ? result.unwrap() : false;
  }

  Future<int> getPointsPerBatchPreference() async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return 0;
    }
    final Option<int> result =
        await _trackerPreferencesRepository.getPointsPerBatchPreference(userId);

    return result.isSome() ? result.unwrap() : 50;
  }

  Future<int> getTrackingFrequencyPreference() async {
    final int? userId = await _user.getUser();
    if (userId == null) {
      return 0;
    }
    final Option<int> result = await _trackerPreferencesRepository
        .getTrackingFrequencyPreference(userId);

    return result.isSome() ? result.unwrap() : 10;
  }

  Future<LocationAccuracy> getLocationAccuracyPreference() async {
    final int? userId = await _user.getUser();

    if (userId == null) {
      return null!;
    }

    final Option<int> accuracyIndex = await _trackerPreferencesRepository
        .getLocationAccuracyPreference(userId);

    switch (accuracyIndex) {
      case Some(:final value)
          when value >= 0 && value < LocationAccuracy.values.length:
        return LocationAccuracy.values[value];
      default:
        return LocationAccuracy.high;
    }
  }

  Future<int> getMinimumPointDistancePreference() async {
    final int? userId = await _user.getUser();

    if (userId == null) {
      return 0;
    }
    final Option<int> result = await _trackerPreferencesRepository
        .getMinimumPointDistancePreference(userId);

    return result.isSome() ? result.unwrap() : 0;
  }

  Future<String> getTrackerId() async {
    final int? userId = await _user.getUser();

    if (userId == null) {
      return "";
    }

    final Option<String> possibleTrackerId =
        await _trackerPreferencesRepository.getTrackerId(userId);

    if (possibleTrackerId case Some(value: String trackerId)) {
      return trackerId;
    }

    final String deviceModel = await _hardwareRepository.getDeviceModel();

    return deviceModel;
  }
}
