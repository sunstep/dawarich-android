import 'dart:async';

import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/tracking/application/repositories/hardware_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/repositories/tracker_settings_repository.dart';
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

  Future<Stream<int>> watchTrackingFrequencySetting() async {
    final int userId = await _requireUserId();
    return _trackerSettingsRepository.watchTrackingFrequencySetting(userId);
  }

  Future<LocationAccuracy> getLocationAccuracySetting() async {
    final int userId = await _requireUserId();
    final Option<int> accuracyIndex = await _trackerSettingsRepository
        .getLocationAccuracySetting(userId);

    if (accuracyIndex case Some(: final value) when value >= 0 && value < LocationAccuracy.values.length) {
      return LocationAccuracy.values[value];
    }
    return LocationAccuracy.high;

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
  }

  Future<Result<(), String>> setPointsPerBatchSetting(int amount) async {

    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setPointsPerBatchSetting(
          userId, amount);

      return Ok(());
    } catch (e) {
      return Err('Failed to update points per batch: $e');
    }

  }

  Future<Result<(), String>> setTrackingFrequencySetting(int seconds) async {

    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setTrackingFrequencySetting(
          userId, seconds);

      FlutterBackgroundService().invoke('updateFrequency');
      return Ok(());
    } catch (e) {
      return Err('Failed to update tracking frequency: $e');
    }

  }

  Future<Result<(), String>> setLocationAccuracySetting(LocationAccuracy accuracy) async {

    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setLocationAccuracySetting(
          userId, accuracy.index);

      return Ok(());
    } catch (e) {
      return Err('Failed to update location accuracy: $e');
    }

  }

  Future<Result<(), String>> setMinimumPointDistanceSetting(int meters) async {

    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setMinimumPointDistanceSetting(
          userId, meters);

      return Ok(());
    } catch (e) {
      return Err('Failed to update minimum point distance: $e');
    }

  }

  Future<Result<(), String>> setDeviceId(String newId) async {
    try {
      final int userId = await _requireUserId();
      _trackerSettingsRepository.setDeviceId(userId, newId);

      return Ok(());
    } catch (e) {
      return Err('Failed to update device ID: $e');
    }

  }

  Future<bool> resetDeviceId() async {
    final int userId = await _requireUserId();

    bool result = await _trackerSettingsRepository.deleteDeviceId(userId);

    return result;
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
