import 'package:dawarich/core/session/domain/legacy_user_session_repository_interfaces.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class LegacyUserSessionRepository implements ILegacyUserSessionRepository {

  @override
  Future<int> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? 0;
  }

  @override
  Future<void> setCurrentUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}
