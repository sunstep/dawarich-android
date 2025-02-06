
abstract interface class ITrackerPreferencesRepository {

  Future<void> initialize();

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse);
  Future<void> setPointsPerBatchPreference(int amount);
  Future<void> setTrackingFrequencyPreference(int seconds);
  Future<void> setLocationAccuracyPreference(int accuracy);
  Future<void> setMinimumPointDistancePreference(int meters);
  Future<void> setTrackerId(String newId);
  Future<String> resetTrackerId();

  Future<bool> getAutomaticTrackingPreference();
  Future<int> getPointsPerBatchPreference();
  Future<int> getTrackingFrequencyPreference();
  Future<int> getLocationAccuracyPreference();
  Future<int> getMinimumPointDistancePreference();
  Future<String> getTrackerId();
}