import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesExtensions on SharedPreferences {
  Future<bool> saveObject(String key, Object object) async {
    final String jsonString = jsonEncode(object);
    return await setString(key, jsonString);
  }

  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final String? jsonString = getString(key);
    if (jsonString == null) return null;
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return fromJson(json);
  }
}