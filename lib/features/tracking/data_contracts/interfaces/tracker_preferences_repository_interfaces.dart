import 'package:option_result/option_result.dart';

abstract interface class ITrackerPreferencesRepository {

  Future<Option<bool>> getAutomaticTrackingPreference(int userId);
  Future<Option<int>> getPointsPerBatchPreference(int userId);
  Future<Option<int>> getTrackingFrequencyPreference(int userId);
  Future<Option<int>> getLocationAccuracyPreference(int userId);
  Future<Option<int>> getMinimumPointDistancePreference(int userId);
  Future<Option<String>> getDeviceId(int userId);

  void setAutomaticTrackingPreference(int userId, bool trueOrFalse);
  void setPointsPerBatchPreference(int userId, int amount);
  void setTrackingFrequencyPreference(int userId, int seconds);
  void setLocationAccuracyPreference(int userId, int accuracy);
  void setMinimumPointDistancePreference(int userId, int meters);
  void setDeviceId(int userId, String newId);
  Future<bool> deleteDeviceId(int userId);

  void clearCaches(int userId);

  Future<void> persistPreferences(int userId);
}
