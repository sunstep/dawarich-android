
import 'package:dawarich/core/database/drift/database/sqlite_client.dart';
import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_dto.dart';

extension DriftUserMapper on UserTableData {

  /// Converts a [UserTableData] instance to a [UserDto].
  UserDto toDto() {
    return UserDto(
      id: id,
      remoteId: dawarichId,
      dawarichEndpoint: dawarichEndpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      theme: theme,
      admin: admin,
    );
  }
}