import 'package:dawarich/data/sources/local/database/user_storage_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';

class UserStorageRepository implements IUserStorageRepository {

  final UserStorageClient _client;
  UserStorageRepository(this._client);

  @override
  Future<void> storeUser(UserDto user) async {

    int userId = await _client.tryStoreUser(user);
    await _client.storeUserSettings(userId, user.userSettings);
  }

  // @override
  // Future<Option<UserDto>> getStoredUser() => _client.getStoredUser();
  //
  // @override
  // Future<int> getLoggedInUserId() => _client.getLoggedInUserId();

  // @override
  // Future<void> clearUser() => _client.clearUser();
  //
  // @override
  // Future<bool> hasStoredUser() => _client.hasStoredUser();

}
