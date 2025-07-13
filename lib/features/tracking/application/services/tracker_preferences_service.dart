import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class TrackerPreferencesService {

  final ITrackerPreferencesRepository _trackerPreferencesRepository;
  final IHardwareRepository _hardwareRepository;
  final SessionBox<User> _user;
  TrackerPreferencesService(
      this._trackerPreferencesRepository, this._hardwareRepository, this._user);

  Future<bool> getAutomaticTrackingPreference() async {
    final int userId = await _requireUserId();

    final Option<bool> result = await _trackerPreferencesRepository
        .getAutomaticTrackingPreference(userId);

    return result.isSome() ? result.unwrap() : false;
  }

  Future<int> getPointsPerBatchPreference() async {
    final int userId = await _requireUserId();
    final Option<int> result =
    await _trackerPreferencesRepository.getPointsPerBatchPreference(userId);

    return result.isSome() ? result.unwrap() : 50;
  }

  Future<int> getTrackingFrequencyPreference() async {
    final int userId = await _requireUserId();
    final Option<int> result = await _trackerPreferencesRepository
        .getTrackingFrequencyPreference(userId);

    return result.isSome() ? result.unwrap() : 10;
  }

  Future<LocationAccuracy> getLocationAccuracyPreference() async {
    final int userId = await _requireUserId();
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
    final int userId = await _requireUserId();
    final Option<int> result = await _trackerPreferencesRepository
        .getMinimumPointDistancePreference(userId);

    return result.isSome() ? result.unwrap() : 0;
  }

  Future<String> getDeviceId() async {
    final int userId = await _requireUserId();

    final Option<String> possibleDeviceId =
    await _trackerPreferencesRepository.getDeviceId(userId);

    if (possibleDeviceId case Some(value: String deviceId)) {
      return deviceId;
    }

    final String deviceModel = await _hardwareRepository.getDeviceModel();

    return deviceModel;
  }

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {
    final int userId = await _requireUserId();

    _trackerPreferencesRepository.setAutomaticTrackingPreference(
        userId, trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.setPointsPerBatchPreference(
        userId, amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.setTrackingFrequencyPreference(
        userId, seconds);
  }

  Future<void> setLocationAccuracyPreference(LocationAccuracy accuracy) async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.setLocationAccuracyPreference(
        userId, accuracy.index);
  }

  Future<void> setMinimumPointDistancePreference(int meters) async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.setMinimumPointDistancePreference(
        userId, meters);
  }

  Future<void> setDeviceId(String newId) async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.setDeviceId(userId, newId);
  }

  Future<bool> resetDeviceId() async {
    final int userId = await _requireUserId();
    return await _trackerPreferencesRepository.deleteDeviceId(userId);
  }

  Future<void> clearCache() async {
    final int userId = await _requireUserId();
    _trackerPreferencesRepository.clearCaches(userId);
  }

  Future<void> persistPreferences() async {

    final int userId = await _requireUserId();

    await _trackerPreferencesRepository.persistPreferences(userId);
  }

  Future<int> _requireUserId() async {
    final int? userId = _user.getUserId();
    if (userId == null) {
      await _user.logout();
      throw Exception('[TrackerPreferencesService] No user session found.');
    }
    return userId;
  }

}
