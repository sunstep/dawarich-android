
import 'package:dawarich/core/database/objectbox/entities/user/user_entity.dart';
import 'package:dawarich/features/auth/data_contracts/data_transfer_objects/users/user_dto.dart';
import 'package:dawarich/features/auth/data_contracts/interfaces/user_storage_repository_interfaces.dart';
import 'package:dawarich/objectbox.g.dart';
import 'package:flutter/foundation.dart';

/// ALWAYS check for empty tables before running any GET operations
/// Or else experience the "Pure virtual function called!" crash.
final class ObjectBoxUserStorageRepository implements IUserStorageRepository {

  final Store _database;
  ObjectBoxUserStorageRepository(this._database);

  @override
  Future<int> storeUser(UserDto user) async {

    try {
      Box<UserEntity> userBox = Box<UserEntity>(_database);

      UserEntity entity = UserEntity(
          remoteId: user.remoteId,
          dawarichHost: user.dawarichEndpoint,
          email: user.email,
          createdAt: user.createdAt,
          theme: user.theme,
          admin: user.admin
      );

      return userBox.put(entity);
    } on ObjectBoxException catch (e) {

      if (kDebugMode) {
        debugPrint('Failed to store user: $e');
      }

      rethrow;
    }

  }

}