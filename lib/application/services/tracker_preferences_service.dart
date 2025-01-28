import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:geolocator/geolocator.dart';

class TrackerPreferencesService {

 final ITrackerPreferencesRepository _trackerPreferencesRepository;
  TrackerPreferencesService(this._trackerPreferencesRepository);

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



}