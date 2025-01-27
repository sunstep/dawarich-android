
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPreferencesService {

 final ITrackerPreferencesRepository _userPreferencesRepository;
  TrackerPreferencesService(this._userPreferencesRepository);

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    await _userPreferencesRepository.setAutomaticTrackingPreference(trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {
    await _userPreferencesRepository.setPointsPerBatchPreference(amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    await _userPreferencesRepository.setTrackingFrequencyPreference(seconds);
  }

  Future<void> setLocationAccuracyPreference(LocationAccuracy accuracy) async {
    await _userPreferencesRepository.setLocationAccuracyPreference(accuracy.index);
  }

  Future<bool> getAutomaticTrackingPreference() async {
    return await _userPreferencesRepository.getAutomaticTrackingPreference();
  }

  Future<int> getPointsPerBatchPreference() async {
    return await _userPreferencesRepository.getPointsPerBatchPreference();
  }

  Future<int> getTrackingFrequencyPreference() async {
    return await _userPreferencesRepository.getTrackingFrequencyPreference();
  }

  Future<LocationAccuracy> getLocationAccuracyPreference() async {

    final int accuracyIndex = await _userPreferencesRepository.getLocationAccuracyPreference();

    if (accuracyIndex >= 0 && accuracyIndex < LocationAccuracy.values.length) {
      return LocationAccuracy.values[accuracyIndex];
    } else {
      return LocationAccuracy.high;
    }
  }



}