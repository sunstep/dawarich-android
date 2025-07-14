import 'package:dawarich/features/tracking/data/utils/preference_keys/tracker_keys.dart';
import 'package:dawarich/features/tracking/data_contracts/data_transfer_objects/settings/tracker_settings_dto.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_settings_repository.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class TrackerSettingsRepository implements ITrackerSettingsRepository {

  // We use this as a quick cache to reduce i/o operations.
  TrackerSettingsDto? _trackerSettings;


  // The methods below should be self-explanatory.
  // 1. Turn settings field into a local variable, either as is, or as a new variable.
  // 2. Get and return the value if cached
  // 3. If not cached, get the value from SharedPreferences, and set it in cache.
  // 4. If not cached nor persisted, then return None.

  @override
  Future<Option<bool>> getAutomaticTrackingSetting(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final bool? value = trackerSettingsCopy.automaticTracking;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final prefs = await SharedPreferences.getInstance();
    final bool? setting = prefs.getBool(TrackerKeys.automaticTrackingKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        automaticTracking: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }


  @override
  Future<Option<int>> getPointsPerBatchSetting(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final int? value = trackerSettingsCopy.pointsPerBatch;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? setting = prefs.getInt(TrackerKeys.pointsPerBatchKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        pointsPerBatch: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }

  @override
  Future<Option<int>> getTrackingFrequencySetting(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final int? value = trackerSettingsCopy.trackingFrequency;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? setting = prefs.getInt(TrackerKeys.trackingFrequencyKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        trackingFrequency: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }

  @override
  Future<Option<int>> getLocationAccuracySetting(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final int? value = trackerSettingsCopy.locationAccuracy;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? setting = prefs.getInt(TrackerKeys.locationAccuracyKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        locationAccuracy: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }

  @override
  Future<Option<int>> getMinimumPointDistanceSetting(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final int? value = trackerSettingsCopy.minimumPointDistance;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? setting = prefs.getInt(TrackerKeys.minimumPointDistanceKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        minimumPointDistance: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }

  @override
  Future<Option<String>> getDeviceId(int userId) async {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    final String? value = trackerSettingsCopy.deviceId;

    if (trackerSettingsCopy.userId == userId && value != null) {
      return Some(value);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? setting = prefs.getString(TrackerKeys.deviceIdKey(userId));

    if (setting != null) {
      TrackerSettingsDto updatedTrackerSettings = trackerSettingsCopy.copyWith(
        deviceId: setting,
      );

      _trackerSettings = updatedTrackerSettings;
      return Some(setting);
    }

    return const None();
  }


  // The code below is already self explanatory, but here are the steps they take in short:
  // 1. Get the current tracker settings or create a new one if it doesn't exist.
  // 2. Create a copy of the current settings with the updated value.
  // 3. Update the tracker settings with the new value.

  @override
  void setAutomaticTrackingSetting(int userId, bool trueOrFalse) {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      automaticTracking: trueOrFalse,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  void setPointsPerBatchSetting(int userId, int amount) {

    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      pointsPerBatch: amount,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  void setTrackingFrequencySetting(int userId, int seconds) {
    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      trackingFrequency: seconds,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  void setLocationAccuracySetting(int userId, int accuracy) {
    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      locationAccuracy: accuracy,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  void setMinimumPointDistanceSetting(int userId, int meters) {
    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      minimumPointDistance: meters,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  void setDeviceId(int userId, String newId) {
    TrackerSettingsDto trackerSettingsCopy = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    TrackerSettingsDto updatedSetting = trackerSettingsCopy.copyWith(
      deviceId: newId,
    );

    _trackerSettings = updatedSetting;
  }

  @override
  Future<bool> deleteDeviceId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(TrackerKeys.deviceIdKey(userId));
  }


  @override
  Future<Option<TrackerSettingsDto>> getTrackerSettings(int userId) async {

    TrackerSettingsDto trackerSettingsCache = _trackerSettings
        ?? TrackerSettingsDto(userId: userId);

    if (trackerSettingsCache != TrackerSettingsDto.empty(userId)) {
      return Some(trackerSettingsCache);
    }

    final prefs = await SharedPreferences.getInstance();

    final dto = TrackerSettingsDto(
      userId: userId,
      automaticTracking: prefs.getBool(TrackerKeys.automaticTrackingKey(userId)),
      trackingFrequency: prefs.getInt(TrackerKeys.trackingFrequencyKey(userId)),
      locationAccuracy: prefs.getInt(TrackerKeys.locationAccuracyKey(userId)),
      minimumPointDistance: prefs.getInt(TrackerKeys.minimumPointDistanceKey(userId)),
      pointsPerBatch: prefs.getInt(TrackerKeys.pointsPerBatchKey(userId)),
      deviceId: prefs.getString(TrackerKeys.deviceIdKey(userId)),
    );

    final isEmpty = dto == TrackerSettingsDto.empty(userId);

    if (!isEmpty) {
      _trackerSettings = dto;
      return Some(dto);
    }

    return const None();
  }

  @override
  void setAll(TrackerSettingsDto settings) {
    _trackerSettings = settings;
  }

  @override
  void clearCaches(int userId) {
    _trackerSettings = null;
  }


  @override
  Future<void> persistPreferences(int userId) async {

    if (_trackerSettings == null || _trackerSettings!.userId != userId) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    final settings = _trackerSettings!;

    if (settings.automaticTracking != null) {
      prefs.setBool(
        TrackerKeys.automaticTrackingKey(userId),
        settings.automaticTracking!,
      );
    }

    if (settings.pointsPerBatch != null) {
      prefs.setInt(
        TrackerKeys.pointsPerBatchKey(userId),
        settings.pointsPerBatch!,
      );
    }

    if (settings.trackingFrequency != null) {
      prefs.setInt(
        TrackerKeys.trackingFrequencyKey(userId),
        settings.trackingFrequency!,
      );
    }

    if (settings.locationAccuracy != null) {
      prefs.setInt(
        TrackerKeys.locationAccuracyKey(userId),
        settings.locationAccuracy!,
      );
    }

    if (settings.minimumPointDistance != null) {
      prefs.setInt(
        TrackerKeys.minimumPointDistanceKey(userId),
        settings.minimumPointDistance!,
      );
    }

    if (settings.deviceId != null) {
      prefs.setString(
        TrackerKeys.deviceIdKey(userId),
        settings.deviceId!,
      );
    }
  }
}
