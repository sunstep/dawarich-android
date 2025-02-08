
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:option_result/option.dart';

abstract class IUserStorageRepository {
  Future<void> storeUser();
  Future<Option<UserDto>> getStoredUser();
  Future<int> getLoggedInUserId();
  Future<void> clearUser();
  Future<bool> hasStoredUser();
  void setUser(UserDto userToStore);
}
