import 'package:dawarich/data/sources/local/shared_preferences/user_storage_client.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerPreferencesClient {

  int _userId = 0;

  final UserStorageClient _userStorageClient;
  TrackerPreferencesClient(this._userStorageClient);

  Future<void> initialize() async {
    _userId = await _userStorageClient.getLoggedInUserId();
  }

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("${_userId}_automaticTracking", trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("${_userId}_pointsPerBatch", amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("${_userId}_trackingFrequency", seconds);
  }

  Future<void> setLocationAccuracyPreference(int accuracy) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("${_userId}_locationAccuracy", accuracy);
  }

  Future<void> setMinimumPointDistancePreference(int meters) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("${_userId}_minimumPointDistance", meters);
  }

  Future<void> setTrackerId(String newId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("${_userId}_trackerId", newId);
  }

  Future<Option<bool>> getAutomaticTrackingPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? preference = prefs.getBool("${_userId}_automaticTracking");

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getPointsPerBatchPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt("${_userId}_pointsPerBatch");

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getTrackingFrequencyPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt("${_userId}_trackingFrequency");

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getLocationAccuracyPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt("${_userId}_locationAccuracy");

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getMinimumPointDistancePreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt("${_userId}_minimumPointDistance");

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<String>> getTrackerId() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? trackerId = prefs.getString("${_userId}_trackerId");

    if (trackerId != null) {
      return Some(trackerId);
    }

    return const None();
  }


}