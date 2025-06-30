import 'package:dawarich/features/tracking/data/utils/preference_keys/tracker_keys.dart';
import 'package:dawarich/features/tracking/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class TrackerPreferencesRepository
    implements ITrackerPreferencesRepository {

  final Map<int, bool> _automaticTrackingCache = {};
  final Map<int, int> _pointsPerBatchCache = {};
  final Map<int, int> _trackingFrequencyCache = {};
  final Map<int, int> _locationAccuracyCache = {};
  final Map<int, int> _minimumPointDistanceCache = {};
  final Map<int, String> _deviceIdCache = {};

  @override
  Future<Option<bool>> getAutomaticTrackingPreference(int userId) async {

    if (_automaticTrackingCache.containsKey(userId)) {
      return Some(_automaticTrackingCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? preference = prefs.getBool(TrackerKeys.automaticTrackingKey(userId));

    if (preference != null) {
      _automaticTrackingCache[userId] = preference;
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getPointsPerBatchPreference(int userId) async {

    if (_pointsPerBatchCache.containsKey(userId)) {
      return Some(_pointsPerBatchCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? preference = prefs.getInt(TrackerKeys.pointsPerBatchKey(userId));

    if (preference != null) {
      _pointsPerBatchCache[userId] = preference;
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getTrackingFrequencyPreference(int userId) async {

    if (_trackingFrequencyCache.containsKey(userId)) {
      return Some(_trackingFrequencyCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.trackingFrequencyKey(userId));

    if (preference != null) {

      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getLocationAccuracyPreference(int userId) async {

    if (_locationAccuracyCache.containsKey(userId)) {
      return Some(_locationAccuracyCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.locationAccuracyKey(userId));

    if (preference != null) {
      _locationAccuracyCache[userId] = preference;
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getMinimumPointDistancePreference(int userId) async {

    if (_minimumPointDistanceCache.containsKey(userId)) {
      return Some(_minimumPointDistanceCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.minimumPointDistanceKey(userId));

    if (preference != null) {
      _minimumPointDistanceCache[userId] = preference;
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<String>> getDeviceId(int userId) async {

    if (_deviceIdCache.containsKey(userId)) {
      return Some(_deviceIdCache[userId]!);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? trackerId = prefs.getString(TrackerKeys.deviceIdKey(userId));

    if (trackerId != null) {
      _deviceIdCache[userId] = trackerId;
      return Some(trackerId);
    }

    return const None();
  }


  @override
  void setAutomaticTrackingPreference(
      int userId, bool trueOrFalse) {
    _automaticTrackingCache[userId] = trueOrFalse;
  }

  @override
  void setPointsPerBatchPreference(int userId, int amount) {
    _pointsPerBatchCache[userId] = amount;
  }

  @override
  void setTrackingFrequencyPreference(int userId, int seconds) {
    _trackingFrequencyCache[userId] = seconds;
  }

  @override
  void setLocationAccuracyPreference(int userId, int accuracy) {
    _locationAccuracyCache[userId] = accuracy;
  }

  @override
  void setMinimumPointDistancePreference(int userId, int meters) {
    _minimumPointDistanceCache[userId] = meters;
  }

  @override
  void setDeviceId(int userId, String newId) {
    _deviceIdCache[userId] = newId;
  }

  @override
  Future<bool> deleteDeviceId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(TrackerKeys.deviceIdKey(userId));
  }

  @override
  void clearCaches(int userId) {
    _automaticTrackingCache.removeWhere((key, _) => key == userId);
    _pointsPerBatchCache.removeWhere((key, _) => key == userId);
    _trackingFrequencyCache.removeWhere((key, _) => key == userId);
    _locationAccuracyCache.removeWhere((key, _) => key == userId);
    _minimumPointDistanceCache.removeWhere((key, _) => key == userId);
    _deviceIdCache.removeWhere((key, _) => key == userId);
  }


  @override
  Future<void> persistPreferences(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_automaticTrackingCache.containsKey(userId)) {
      prefs.setBool(TrackerKeys.automaticTrackingKey(userId),
          _automaticTrackingCache[userId]!);
    }

    if (_pointsPerBatchCache.containsKey(userId)) {
      prefs.setInt(
          TrackerKeys.pointsPerBatchKey(userId), _pointsPerBatchCache[userId]!);
    }

    if (_trackingFrequencyCache.containsKey(userId)) {
      prefs.setInt(TrackerKeys.trackingFrequencyKey(userId),
          _trackingFrequencyCache[userId]!);
    }

    if (_locationAccuracyCache.containsKey(userId)) {
      prefs.setInt(TrackerKeys.locationAccuracyKey(userId),
          _locationAccuracyCache[userId]!);
    }

    if (_minimumPointDistanceCache.containsKey(userId)) {
      prefs.setInt(TrackerKeys.minimumPointDistanceKey(userId),
          _minimumPointDistanceCache[userId]!);
    }

    if (_deviceIdCache.containsKey(userId)) {
      prefs.setString(TrackerKeys.deviceIdKey(userId), _deviceIdCache[userId]!);
    }
  }
}
