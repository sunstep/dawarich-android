import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:option_result/option_result.dart';

abstract class IUserRepository {
  Future<int> storeUser(UserDto user);
  Future<Option<UserDto>> getUserByRemoteId(String host, int remoteId);
  Future<Option<UserDto>> getUserByEmail(String? host, String email);
  // Future<int> getLoggedInUserId();
  // Future<void> clearUser();
  // Future<bool> hasStoredUser();
}
