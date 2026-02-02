
import 'package:dawarich/core/data/drift/database/sqlite_client.dart';
import 'package:dawarich/core/domain/models/user.dart';

extension DriftUserMapper on UserTableData {

  /// Converts a [UserTableData] instance to a [User].
  User toDomain() {
    return User(
      id: id,
      remoteId: dawarichId,
      dawarichHost: dawarichEndpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      theme: theme,
      admin: admin,
    );
  }
}