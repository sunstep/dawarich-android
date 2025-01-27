
abstract interface class ITrackerPreferencesRepository {

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse);
  Future<void> setPointsPerBatchPreference(int amount);
  Future<void> setTrackingFrequencyPreference(int seconds);
  Future<void> setLocationAccuracyPreference(int accuracy);

  Future<bool> getAutomaticTrackingPreference();
  Future<int> getPointsPerBatchPreference();
  Future<int> getTrackingFrequencyPreference();
  Future<int> getLocationAccuracyPreference();
}