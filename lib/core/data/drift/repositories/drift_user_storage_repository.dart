import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_dto.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_settings_dto.dart';
import 'package:dawarich/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:drift/drift.dart';
import 'package:option_result/option_result.dart';

@Deprecated('Use objectbox instead')
final class DriftUserStorageRepository implements IUserStorageRepository {
  final SQLiteClient _database;
  DriftUserStorageRepository(this._database);

  @Deprecated('Drift DAL is no longer in use, look at ObjectBox DAL for actual functionality.')
  Future<Option<UserDto>> _findDawarichUser(
      int dawarichId, String endpoint) async {
    final userQuery = _database.select(_database.userTable)
      ..where((u) =>
          u.dawarichId.equals(dawarichId) &
          u.dawarichEndpoint.equals(endpoint));

    final UserTableData? userResult = await userQuery.getSingleOrNull();

    if (userResult != null) {
      return Some(UserDto.fromDatabase(userResult));
    }
    return const None();
  }

  @Deprecated('Drift DAL is no longer in use, look at ObjectBox DAL for actual functionality.')
  @override
  Future<int> storeUser(UserDto userDto) async {
    if (userDto.remoteId != null && userDto.dawarichEndpoint != null) {
      Option<UserDto> userResult =
          await _findDawarichUser(userDto.remoteId!, userDto.dawarichEndpoint!);

      if (userResult case Some(value: UserDto user)) {
        return user.id;
      }
    }

    return await _database.into(_database.userTable).insertOnConflictUpdate(
          UserTableCompanion(
              dawarichId: Value(userDto.remoteId),
              dawarichEndpoint: Value(userDto.dawarichEndpoint),
              email: Value(userDto.email),
              createdAt: Value(userDto.createdAt),
              updatedAt: Value(userDto.updatedAt),
              theme: Value(userDto.theme),
              admin: Value(userDto.admin)),
        );
  }

  // Future<Option<UserSettingsDto>> _getUserSettings(int userId) async {
  //
  //   final query = _database
  //     .select(_database.userSettingsTable)
  //       ..where((tbl) => tbl.userId.equals(userId)
  //   );
  //   final UserSettingsTableData? result = await query.getSingleOrNull();
  //   if (result != null) {
  //     return Some(UserSettingsDto.fromDatabase(result));
  //   }
  //
  //   return const None();
  //
  // }

  Future<void> storeUserSettings(
      int localUserId, UserSettingsDto userSettings) async {
    _database.into(_database.userSettingsTable).insert(
        UserSettingsTableCompanion(
            immichUrl: Value(userSettings.immichUrl),
            immichApiKey: Value(userSettings.immichApiKey),
            photoprismUrl: Value(userSettings.photoprismUrl),
            photoprismApiKey: Value(userSettings.photoprismApiKey),
            userId: Value(localUserId)));
  }

  // Future<Option<UserDto>> getStoredUser() async {
  //
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   UserDto? user = prefs.getObject<UserDto>("user", (json) => UserDto.fromJson(json));
  //
  //   if (user != null){
  //     return Some(user);
  //   }
  //
  //   return const None();
  // }
  //
  // Future<int> getLoggedInUserId() async {
  //
  //   Option<UserDto> userResult = await getStoredUser();
  //
  //   switch (userResult) {
  //
  //     case Some(value: UserDto user): {
  //       return user.id;
  //     }
  //
  //     case None(): {
  //       throw StateError("A user id should be present at this point.");
  //     }
  //   }
  // }
}
