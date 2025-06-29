import 'package:option_result/option_result.dart';

abstract interface class ITrackerPreferencesRepository {
  Future<void> setAutomaticTrackingPreference(int userId, bool trueOrFalse);
  Future<void> setPointsPerBatchPreference(int userId, int amount);
  Future<void> setTrackingFrequencyPreference(int userId, int seconds);
  Future<void> setLocationAccuracyPreference(int userId, int accuracy);
  Future<void> setMinimumPointDistancePreference(int userId, int meters);
  Future<void> setTrackerId(int userId, String newId);
  Future<bool> deleteTrackerId(int userId);

  Future<Option<bool>> getAutomaticTrackingPreference(int userId);
  Future<Option<int>> getPointsPerBatchPreference(int userId);
  Future<Option<int>> getTrackingFrequencyPreference(int userId);
  Future<Option<int>> getLocationAccuracyPreference(int userId);
  Future<Option<int>> getMinimumPointDistancePreference(int userId);
  Future<Option<String>> getTrackerId(int userId);
}
