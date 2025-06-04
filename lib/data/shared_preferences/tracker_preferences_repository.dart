import 'package:dawarich/data/utils/preference_keys/tracker_keys.dart';
import 'package:dawarich/data_contracts/interfaces/tracker_preferences_repository_interfaces.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class TrackerPreferencesRepository implements ITrackerPreferencesRepository {

  @override
  Future<void> setAutomaticTrackingPreference(int userId, bool trueOrFalse) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(TrackerKeys.automaticTrackingKey(userId), trueOrFalse);
  }

  @override
  Future<void> setPointsPerBatchPreference(int userId, int amount) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.pointsPerBatchKey(userId), amount);
  }

  @override
  Future<void> setTrackingFrequencyPreference(int userId, int seconds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.trackingFrequencyKey(userId), seconds);
  }

  @override
  Future<void> setLocationAccuracyPreference(int userId, int accuracy) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.locationAccuracyKey(userId), accuracy);
  }

  @override
  Future<void> setMinimumPointDistancePreference(int userId, int meters) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.minimumPointDistanceKey(userId), meters);
  }

  @override
  Future<void> setTrackerId(int userId, String newId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(TrackerKeys.trackerIdKey(userId), newId);
  }

  @override
  Future<bool> deleteTrackerId(int userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(TrackerKeys.trackerIdKey(userId));
  }

  @override
  Future<Option<bool>> getAutomaticTrackingPreference(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? preference = prefs.getBool(TrackerKeys.automaticTrackingKey(userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getPointsPerBatchPreference(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.pointsPerBatchKey(userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getTrackingFrequencyPreference(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.trackingFrequencyKey(userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getLocationAccuracyPreference(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.locationAccuracyKey(userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<int>> getMinimumPointDistancePreference(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.minimumPointDistanceKey(userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  @override
  Future<Option<String>> getTrackerId(int userId) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? trackerId = prefs.getString(TrackerKeys.trackerIdKey(userId));

    if (trackerId != null) {
      return Some(trackerId);
    }

    return const None();
  }


}