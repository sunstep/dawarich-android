

import 'package:dawarich/data/sources/local/shared_preferences/user_storage_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:option_result/option.dart';

class UserStorageRepository implements IUserStorageRepository {

  final UserStorageClient _client;

  UserStorageRepository(this._client);

  @override
  Future<void> storeUser() => _client.storeUser();

  @override
  Future<Option<UserDto>> getStoredUser() => _client.getStoredUser();

  @override
  Future<int> getLoggedInUserId() => _client.getLoggedInUserId();

  @override
  Future<void> clearUser() => _client.clearUser();

  @override
  Future<bool> hasStoredUser() => _client.hasStoredUser();

  @override
  void setUser(UserDto userToStore) => _client.setUser(userToStore);
}
