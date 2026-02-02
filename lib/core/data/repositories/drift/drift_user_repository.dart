
import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/core/data/drift/extensions/mappers/user_mapper.dart';
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/application/repositories/user_repository_interfaces.dart';
import 'package:drift/drift.dart';
import 'package:option_result/option_result.dart';

final class DriftUserRepository implements IUserRepository {

  final SQLiteClient _database;
  DriftUserRepository(this._database);

  @override
  Future<int> storeUser(User user) async {

    final String? dawarichHost = user.dawarichHost;
    final int? remoteId = user.remoteId;

    if (dawarichHost != null && remoteId != null) {

      Option<User> userResult =
          await getUserByRemoteId(dawarichHost, remoteId);

      if (userResult case Some(value: User existingUser)) {
        return existingUser.id;
      }
    } else {
      Option<User> userResult =
          await getUserByEmail(dawarichHost, user.email);

      if (userResult case Some(value: User existingUser)) {
        return existingUser.id;
      }
    }

    return _database.transaction(() async {
      // 1) Upsert user
      final userId = await _database.into(_database.userTable).insertOnConflictUpdate(
        UserTableCompanion(
          // if your PK is autoincrement, omit id; otherwise include it
          id: user.id > 0 ? Value(user.id) : const Value.absent(),
          dawarichId: Value(user.remoteId),
          dawarichEndpoint: Value(user.dawarichHost),
          email: Value(user.email),
          createdAt: Value(user.createdAt),
          updatedAt: Value(user.updatedAt),
          theme: Value(user.theme),
          admin: Value(user.admin),
        ),
      );

      // 2) Upsert settings (if present)
      // final s = user.settings;
      // if (s != null) {
      //   await _database
      //       .into(_database.userSettingsTable)
      //       .insertOnConflictUpdate(UserSettingsTableCompanion(
      //     userId: Value(userId), // FK to user
      //     distanceUnit: Value(s.maps?.distanceUnit),
      //     fogOfWarMeters: Value(s.fogOfWarMeters),
      //     metersBetweenRoutes: Value(s.metersBetweenRoutes),
      //     preferredMapLayer: Value(s.preferredMapLayer),
      //     speedColoredRoutes: Value(s.speedColoredRoutes),
      //     pointsRenderingMode: Value(s.pointsRenderingMode),
      //     minutesBetweenRoutes: Value(s.minutesBetweenRoutes),
      //     timeThresholdMinutes: Value(s.timeThresholdMinutes),
      //     mergeThresholdMinutes: Value(s.mergeThresholdMinutes),
      //     liveMapEnabled: Value(s.liveMapEnabled),
      //     routeOpacity: Value(s.routeOpacity),
      //     immichUrl: Value(s.immichUrl),
      //     photoprismUrl: Value(s.photoprismUrl),
      //     visitsSuggestionsEnabled: Value(s.visitsSuggestionsEnabled),
      //     // optional/nullables:
      //     speedColorScale: const Value.absent(),   // map if you have a column
      //     fogOfWarThreshold: const Value.absent(), // map if you have a column
      //   ));
      // }

      return userId;
    });
  }


  @override
  Future<Option<User>> getUserByRemoteId(
      String host, int remoteId) async {
    final userQuery = _database.select(_database.userTable)
      ..where((u) =>
      u.dawarichId.equals(remoteId) &
      u.dawarichEndpoint.equals(host));

    final UserTableData? userResult = await userQuery.getSingleOrNull();

    if (userResult != null) {
      return Some(userResult.toDomain());
    }
    return const None();
  }

  @override
  Future<Option<User>> getUserByEmail(String? host, String email) async {

    final userQuery = (_database.select(_database.userTable)
      ..where((u) => u.email.equals(email) &
      (host == null
          ? u.dawarichEndpoint.isNull()
          : u.dawarichEndpoint.equals(host))
      ));

    final UserTableData? userResult = await userQuery.getSingleOrNull();

    if (userResult != null) {
      return Some(userResult.toDomain());
    }

    return const None();
  }

  // Future<int> getLoggedInUserId() async {
  //
  //   Option<UserDto> userResult = await getUserByEmail();
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

  // Future<void> storeUserSettings(
  //     int localUserId, UserSettingsDto userSettings) async {
  //   _database.into(_database.userSettingsTable).insert(
  //       UserSettingsTableCompanion(
  //           immichUrl: Value(userSettings.immichUrl),
  //           immichApiKey: Value(userSettings.immichApiKey),
  //           photoprismUrl: Value(userSettings.photoprismUrl),
  //           photoprismApiKey: Value(userSettings.photoprismApiKey),
  //           userId: Value(localUserId)));
  // }


}
