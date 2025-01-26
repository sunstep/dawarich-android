
import 'package:dawarich/data/sources/local/shared_preferences/shared_preference_extensions.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorageClient {

  UserDto? _user;
  UserDto? get user => _user;

  void setUser(UserDto userToStore) {
    _user = userToStore;
  }

  Future<void> storeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final UserDto? user = _user;

    if (user != null) {
      await prefs.saveObject("user", user.toJson());
    }
  }

  Future<UserDto?> getStoredUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getObject("user", (json) => UserDto.fromJson(json));
  }

  Future<int> getLoggedInUserId() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserDto? user = prefs.getObject("user", (json) => UserDto.fromJson(json));
    int userId = 0;

    if (user != null) {
      userId = user.id;
    }

    return userId;
  }

  Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("user");
    _user = null;
  }

  Future<bool> hasStoredUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("user");
  }
}