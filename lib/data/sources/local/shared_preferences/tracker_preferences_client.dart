import 'package:dawarich/data/sources/local/shared_preferences/user_session.dart';
import 'package:dawarich/data/utils/preference_keys/tracker_keys.dart';
import 'package:option_result/option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackerPreferencesClient {

  int _userId = 0;

  final UserSessionClient _userSession;
  TrackerPreferencesClient(this._userSession);

  Future<void> initialize() async {
    await _userSession.loadSession();
    _userId = _userSession.userId;
  }

  Future<void> setAutomaticTrackingPreference(bool trueOrFalse) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(TrackerKeys.automaticTrackingKey(_userId), trueOrFalse);
  }

  Future<void> setPointsPerBatchPreference(int amount) async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.pointsPerBatchKey(_userId), amount);
  }

  Future<void> setTrackingFrequencyPreference(int seconds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.trackingFrequencyKey(_userId), seconds);
  }

  Future<void> setLocationAccuracyPreference(int accuracy) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.locationAccuracyKey(_userId), accuracy);
  }

  Future<void> setMinimumPointDistancePreference(int meters) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(TrackerKeys.minimumPointDistanceKey(_userId), meters);
  }

  Future<void> setTrackerId(String newId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(TrackerKeys.trackerIdKey(_userId), newId);
  }

  Future<bool> deleteTrackerId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(TrackerKeys.trackerIdKey(_userId));
  }

  Future<Option<bool>> getAutomaticTrackingPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? preference = prefs.getBool(TrackerKeys.automaticTrackingKey(_userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getPointsPerBatchPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.pointsPerBatchKey(_userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getTrackingFrequencyPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.trackingFrequencyKey(_userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getLocationAccuracyPreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.locationAccuracyKey(_userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<int>> getMinimumPointDistancePreference() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    int? preference = prefs.getInt(TrackerKeys.minimumPointDistanceKey(_userId));

    if (preference != null) {
      return Some(preference);
    }

    return const None();
  }

  Future<Option<String>> getTrackerId() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? trackerId = prefs.getString(TrackerKeys.trackerIdKey(_userId));

    if (trackerId != null) {
      return Some(trackerId);
    }

    return const None();
  }


}