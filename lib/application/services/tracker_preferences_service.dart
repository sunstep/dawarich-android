import 'package:dawarich/data_contracts/interfaces/hardware_repository_interfaces.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class TrackerPreferencesService {

  final ITrackerPreferencesRepository _trackerPreferencesRepository;
  final IHardwareRepository _hardwareRepository;
  TrackerPreferencesService(this._trackerPreferencesRepository, this._hardwareRepository);

  Future<void> initialize() async {
    await _trackerPreferencesRepository.initialize();
  }

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    await _trackerPreferencesRepository.setAutomaticTrackingPreference(trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {
    await _trackerPreferencesRepository.setPointsPerBatchPreference(amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    await _trackerPreferencesRepository.setTrackingFrequencyPreference(seconds);
  }

  Future<void> setLocationAccuracyPreference(LocationAccuracy accuracy) async {
    await _trackerPreferencesRepository.setLocationAccuracyPreference(accuracy.index);
  }

  Future<void> setMinimumPointDistancePreference(int meters) async {
    await _trackerPreferencesRepository.setMinimumPointDistancePreference(meters);
  }

  Future<void> setTrackerId(String newId) async {
    await _trackerPreferencesRepository.setTrackerId(newId);
  }

  Future<bool> resetTrackerId() async {

    return await _trackerPreferencesRepository.resetTrackerId();
  }

  Future<bool> getAutomaticTrackingPreference() async {
    return await _trackerPreferencesRepository.getAutomaticTrackingPreference();
  }

  Future<int> getPointsPerBatchPreference() async {
    return await _trackerPreferencesRepository.getPointsPerBatchPreference();
  }

  Future<int> getTrackingFrequencyPreference() async {
    return await _trackerPreferencesRepository.getTrackingFrequencyPreference();
  }

  Future<LocationAccuracy> getLocationAccuracyPreference() async {

    final int accuracyIndex = await _trackerPreferencesRepository.getLocationAccuracyPreference();

    if (accuracyIndex >= 0 && accuracyIndex < LocationAccuracy.values.length) {
      return LocationAccuracy.values[accuracyIndex];
    } else {
      return LocationAccuracy.high;
    }
  }

  Future<int> getMinimumPointDistancePreference() async {

    return await _trackerPreferencesRepository.getMinimumPointDistancePreference();
  }

  Future<String> getTrackerId() async {

    final Option<String> possibleTrackerId =  await _trackerPreferencesRepository.getTrackerId();

    if (possibleTrackerId case Some(value: String trackerId)) {

      return trackerId;
    }

    final String deviceModel = await _hardwareRepository.getDeviceModel();

    return deviceModel;
  }

}