
import 'dart:io';

import 'package:dawarich/data/sources/local/shared_preferences/tracker_preferences_client.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';

class TrackerPreferencesRepository implements ITrackerPreferencesRepository {

  final TrackerPreferencesClient _userPreferencesClient;
  TrackerPreferencesRepository(this._userPreferencesClient);

  @override
  Future<void> initialize() async => await _userPreferencesClient.initialize();

  @override
  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    await _userPreferencesClient.setAutomaticTrackingPreference(trueOrFalse);
  }

  @override
  Future<void> setPointsPerBatchPreference(int amount) async {

    await _userPreferencesClient.setPointsPerBatchPreference(amount);
  }

  @override
  Future<void> setTrackingFrequencyPreference(int seconds) async {
    await _userPreferencesClient.setTrackingFrequencyPreference(seconds);
  }

  @override
  Future<void> setLocationAccuracyPreference(int accuracy) async {
    await _userPreferencesClient.setLocationAccuracyPreference(accuracy);
  }

  @override
  Future<bool> getAutomaticTrackingPreference() async {

    Option<bool> preferenceResult = await _userPreferencesClient.getAutomaticTrackingPreference();

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

    Option<int> preferenceResult = await _userPreferencesClient.getPointsPerBatchPreference();

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

    Option<int> preferenceResult = await _userPreferencesClient.getTrackingFrequencyPreference();

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

    Option<int> preferenceResult = await _userPreferencesClient.getLocationAccuracyPreference();

    switch (preferenceResult) {

      case Some(value: int preference): {
        return preference;
      }

      case None(): {
        return Platform.isIOS ? LocationAccuracy.best.index : LocationAccuracy.high.index;
      }
    }

  }


}