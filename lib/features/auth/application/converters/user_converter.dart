
import 'package:dawarich/core/domain/models/user.dart';
import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_dto.dart';

extension UserDomainDtoConverter on User {

  UserDto toDto() {
    return UserDto(
        id: id,
        remoteId: remoteId,
        dawarichEndpoint: dawarichHost,
        email: email,
        createdAt: createdAt,
        updatedAt: updatedAt,
        theme: theme,
        admin: admin
    );
  }

}

extension UserDtoDomainConverter on UserDto {

  User toDomain() {
    return User(
        id: id,
        remoteId: remoteId,
        dawarichHost: dawarichEndpoint,
        email: email,
        createdAt: createdAt,
        updatedAt: updatedAt,
        theme: theme,
        admin: admin,
        // settings: settings
    );


  }
}