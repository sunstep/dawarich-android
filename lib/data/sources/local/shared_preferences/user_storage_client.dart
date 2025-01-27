
import 'package:dawarich/data/sources/local/shared_preferences/shared_preference_extensions.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:option_result/option.dart';
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

  Future<Option<UserDto>> getStoredUser() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserDto? user = prefs.getObject<UserDto>("user", (json) => UserDto.fromJson(json));

    if (user != null){
      return Some(user);
    }

    return const None();
  }

  Future<int> getLoggedInUserId() async {

    Option<UserDto> userResult = await getStoredUser();

    switch (userResult) {

      case Some(value: UserDto user): {
        return user.id;
      }

      case None(): {
        throw StateError("A user id should be present at this point!");
      }
    }
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