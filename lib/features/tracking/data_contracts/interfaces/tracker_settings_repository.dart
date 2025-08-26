import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class ITrackerSettingsRepository {

  Future<Option<bool>> getAutomaticTrackingSetting(int userId);
  Future<Option<int>> getPointsPerBatchSetting(int userId);
  Future<Option<int>> getTrackingFrequencySetting(int userId);
  Future<Option<int>> getLocationAccuracySetting(int userId);
  Future<Option<int>> getMinimumPointDistanceSetting(int userId);
  Future<Option<String>> getDeviceId(int userId);

  void setAutomaticTrackingSetting(int userId, bool trueOrFalse);
  void setPointsPerBatchSetting(int userId, int amount);
  void setTrackingFrequencySetting(int userId, int seconds);
  void setLocationAccuracySetting(int userId, int accuracy);
  void setMinimumPointDistanceSetting(int userId, int meters);
  void setDeviceId(int userId, String newId);
  Future<bool> deleteDeviceId(int userId);

  Future<Option<TrackerSettingsDto>> getTrackerSettings(int userId);
  void setAll(TrackerSettingsDto settings);
  void clearCaches(int userId);

  Future<void> persistPreferences(int userId);
}
