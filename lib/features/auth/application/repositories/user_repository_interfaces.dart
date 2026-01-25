import 'package:dawarich/core/domain/models/user.dart';
import 'package:option_result/option_result.dart';

abstract class IUserRepository {
  Future<int> storeUser(User user);
  Future<Option<User>> getUserByRemoteId(String host, int remoteId);
  Future<Option<User>> getUserByEmail(String? host, String email);
  // Future<int> getLoggedInUserId();
  // Future<void> clearUser();
  // Future<bool> hasStoredUser();
}
