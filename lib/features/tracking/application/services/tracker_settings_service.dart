import 'dart:async';

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:dawarich/features/tracking/domain/models/tracker_settings.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';
import 'package:session_box/session_box.dart';

final class TrackerSettingsService {

  final ITrackerSettingsRepository _trackerSettingsRepository;
  final IHardwareRepository _hardwareRepository;
  final SessionBox<User> _user;
  TrackerSettingsService(
      this._trackerSettingsRepository, this._hardwareRepository, this._user);

  Future<bool> getAutomaticTrackingSetting() async {
    final int userId = await _requireUserId();

    final Option<bool> result = await _trackerSettingsRepository
        .getAutomaticTrackingSetting(userId);

    return result.isSome() ? result.unwrap() : false;
  }

  Future<int> getPointsPerBatchSetting() async {
    final int userId = await _requireUserId();
    final Option<int> result =
    await _trackerSettingsRepository.getPointsPerBatchSetting(userId);

    return result.isSome() ? result.unwrap() : 50;
  }

  Future<int> getTrackingFrequencySetting() async {
    final int userId = await _requireUserId();
    final Option<int> result = await _trackerSettingsRepository
        .getTrackingFrequencySetting(userId);

    return result.isSome() ? result.unwrap() : 10;
  }

  Future<LocationAccuracy> getLocationAccuracySetting() async {
    final int userId = await _requireUserId();
    final Option<int> accuracyIndex = await _trackerSettingsRepository
        .getLocationAccuracySetting(userId);

    switch (accuracyIndex) {
      case Some(:final value)
      when value >= 0 && value < LocationAccuracy.values.length:
        return LocationAccuracy.values[value];
      default:
        return LocationAccuracy.high;
    }
  }

  Future<int> getMinimumPointDistanceSetting() async {
    final int userId = await _requireUserId();
    final Option<int> result = await _trackerSettingsRepository
        .getMinimumPointDistanceSetting(userId);

    return result.isSome() ? result.unwrap() : 0;
  }

  Future<String> getDeviceId() async {
    final int userId = await _requireUserId();

    final Option<String> possibleDeviceId =
    await _trackerSettingsRepository.getDeviceId(userId);

    if (possibleDeviceId case Some(value: String deviceId)) {
      return deviceId;
    }

    final String deviceModel = await _hardwareRepository.getDeviceModel();

    return deviceModel;
  }

  // Future<TrackerSettings> getTrackerSettings() async {
  //
  //   final int userId = await _requireUserId();
  //
  //   final Option<TrackerSettingsDto> settingsOption =
  //       await _trackerSettingsRepository.getTrackerSettings(userId);
  //
  //
  // }

  Future<void> setAutomaticTrackingSetting(bool trueOrFalse) async {
    final int userId = await _requireUserId();

    _trackerSettingsRepository.setAutomaticTrackingSetting(
        userId, trueOrFalse);

    _syncWithBackground();
  }

  Future<void> setPointsPerBatchSetting(int amount) async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.setPointsPerBatchSetting(
        userId, amount);

    _syncWithBackground();
  }

  Future<void> setTrackingFrequencySetting(int seconds) async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.setTrackingFrequencySetting(
        userId, seconds);

    await _syncWithBackground(expectOk: true);
    FlutterBackgroundService().invoke('updateFrequency');
  }

  Future<void> setLocationAccuracySetting(LocationAccuracy accuracy) async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.setLocationAccuracySetting(
        userId, accuracy.index);

    _syncWithBackground();
  }

  Future<void> setMinimumPointDistanceSetting(int meters) async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.setMinimumPointDistanceSetting(
        userId, meters);

    _syncWithBackground();
  }

  Future<void> setDeviceId(String newId) async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.setDeviceId(userId, newId);

    _syncWithBackground();
  }

  Future<bool> resetDeviceId() async {
    final int userId = await _requireUserId();

    bool result = await _trackerSettingsRepository.deleteDeviceId(userId);

    _syncWithBackground();
    return result;
  }

  Future<void> clearCache() async {
    final int userId = await _requireUserId();
    _trackerSettingsRepository.clearCaches(userId);
    _syncWithBackground();
  }

  Future<void> _syncWithBackground({bool expectOk = false}) async {

    final userId = await _requireUserId();

    final settingsResult = await _trackerSettingsRepository
        .getTrackerSettings(userId);

    if (settingsResult case Some(value: final TrackerSettingsDto settingsDto)) {

      final service = FlutterBackgroundService();

      if (expectOk) {
        final completer = Completer<void>();

        service.on('syncSettingsAck').first.then((_) {
          completer.complete();
        });

        service.invoke('syncSettings', settingsDto.toJson());
        await completer.future;
      } else {
        service.invoke('syncSettings', settingsDto.toJson());
      }
    }

  }

  Future<void> persistSettings() async {

    final int userId = await _requireUserId();

    await _trackerSettingsRepository.persistPreferences(userId);
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
