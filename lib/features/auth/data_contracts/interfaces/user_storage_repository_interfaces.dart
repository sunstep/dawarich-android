import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';

abstract class IUserStorageRepository {
  Future<int> storeUser(UserDto user);
  // Future<Option<UserDto>> getStoredUser();
  // Future<int> getLoggedInUserId();
  // Future<void> clearUser();
  // Future<bool> hasStoredUser();
}
