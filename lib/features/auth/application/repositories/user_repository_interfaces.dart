import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_dto.dart';
import 'package:option_result/option_result.dart';

abstract interface class IUserRepository {
  Future<int> storeUser(UserDto user);
  Future<Option<UserDto>> getUserByRemoteId(String host, int remoteId);
  Future<Option<UserDto>> getUserByEmail(String? host, String email);

}
