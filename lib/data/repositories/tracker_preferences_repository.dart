import 'dart:io';
import 'package:dawarich/data/sources/local/shared_preferences/tracker_preferences_client.dart';
import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';

class TrackerPreferencesRepository implements ITrackerPreferencesRepository {

  final TrackerPreferencesClient _trackerPreferencesClient;
  final IHardwareRepository _hardwareRepository;
  TrackerPreferencesRepository(this._trackerPreferencesClient, this._hardwareRepository);

  @override
  Future<void> initialize() async => await _trackerPreferencesClient.initialize();

  @override
  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    await _trackerPreferencesClient.setAutomaticTrackingPreference(trueOrFalse);
  }

  @override
  Future<void> setPointsPerBatchPreference(int amount) async {

    await _trackerPreferencesClient.setPointsPerBatchPreference(amount);
  }

  @override
  Future<void> setTrackingFrequencyPreference(int seconds) async {
    await _trackerPreferencesClient.setTrackingFrequencyPreference(seconds);
  }

  @override
  Future<void> setLocationAccuracyPreference(int accuracy) async {
    await _trackerPreferencesClient.setLocationAccuracyPreference(accuracy);
  }

  @override
  Future<void> setMinimumPointDistancePreference(int meters) async {
    await _trackerPreferencesClient.setMinimumPointDistancePreference(meters);
  }

  @override
  Future<void> setTrackerId(String newId) async {
    await _trackerPreferencesClient.setTrackerId(newId);
  }

  @override
  Future<bool> resetTrackerId() async {
    return await _trackerPreferencesClient.deleteTrackerId();
  }

  @override
  Future<bool> getAutomaticTrackingPreference() async {

    Option<bool> preferenceResult = await _trackerPreferencesClient.getAutomaticTrackingPreference();

    switch (preferenceResult) {

      case Some(value: bool preference): {
        return preference;
      }

    // Fall back to this if the user does not have this setting stored yet. Preferences are never stored and fall back to default values until the user manually changes them.
      case None(): {
        return true;
      }
    }

  }

  @override
  Future<int> getPointsPerBatchPreference() async {

    Option<int> preferenceResult = await _trackerPreferencesClient.getPointsPerBatchPreference();

    switch (preferenceResult) {

      case Some(value: int preference): {
        return preference;
      }

      case None(): {
        return 50;
      }
    }

  }

  @override
  Future<int> getTrackingFrequencyPreference() async {

    Option<int> preferenceResult = await _trackerPreferencesClient.getTrackingFrequencyPreference();

    switch (preferenceResult) {

      case Some(value: int preference): {
        return preference;
      }

      case None(): {
        return 10;
      }
    }

  }

  @override
  Future<int> getLocationAccuracyPreference() async {

    Option<int> preferenceResult = await _trackerPreferencesClient.getLocationAccuracyPreference();

    switch (preferenceResult) {

      case Some(value: int preference): {
        return preference;
      }

      case None(): {
        return Platform.isIOS ? LocationAccuracy.best.index : LocationAccuracy.high.index;
      }
    }
  }

  @override
  Future<int> getMinimumPointDistancePreference() async {

    Option<int> preferenceResult = await _trackerPreferencesClient.getMinimumPointDistancePreference();

    switch (preferenceResult) {

      case Some(value: int preference): {
        return preference;
      }

      case None(): {
        return 0;
      }
    }
  }

  @override
  Future<String> getTrackerId() async {

    Option<String> preferenceResult = await _trackerPreferencesClient.getTrackerId();

    switch (preferenceResult) {

      case Some(value: String trackerId): {
        return trackerId;
      }

      case None(): {
        return await _hardwareRepository.getDeviceModel();
      }
    }
  }


}