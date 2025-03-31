import 'package:shared_preferences/shared_preferences.dart';

final class UserSessionClient {

  static final UserSessionClient _instance = UserSessionClient._internal();
  factory UserSessionClient() => _instance;
  UserSessionClient._internal();

  int userId = 0;
  bool sessionLoaded = false;
  bool get isLoggedIn => userId > 0;

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? 0;
    sessionLoaded = true;
  }

  Future<void> saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId = 0;
    await prefs.remove('userId');
    sessionLoaded = false;
  }


}