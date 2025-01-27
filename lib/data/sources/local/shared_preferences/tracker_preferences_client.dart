
import 'package:dawarich/data/sources/local/shared_preferences/user_storage_client.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerPreferencesClient {

  final int _userId;
  TrackerPreferencesClient._(this._userId);

  static Future<TrackerPreferencesClient> initialize(UserStorageClient userStorageClient) async {
    final int userId = await userStorageClient.getLoggedInUserId();
    return TrackerPreferencesClient._(userId);
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



}