import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Preferences {

  late SharedPreferences _preferences;

  Preferences(){
    //_initialize();
    Future(_initialize);
  }

  Future<void> _initialize() async {
    await getInstance();
  }

  Future<void> getInstance() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  bool? getBool(String key) => _preferences.getBool(key);

  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  int? getInt(String key) => _preferences.getInt(key);

  Future<void> setBoolArray(String key, List<bool> values) async {
    
    final List<String> serializedArray = values.map((value) => jsonEncode(value)).toList();
    await _preferences.setStringList(key, serializedArray);
  }

  Future<List<bool>> getBoolArray(String key, List<String> values) async {
    final List<String>? serializedArray = _preferences.getStringList(key);

    if (serializedArray == null){
      return [false];
    }

    return serializedArray.map((value) => jsonDecode(value) as bool).toList();
  }

}