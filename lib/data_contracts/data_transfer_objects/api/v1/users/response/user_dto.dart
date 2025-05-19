import 'package:dawarich/data/sources/local/database/sqlite_client.dart';
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_settings_dto.dart';

class UserDto {

  final int id;
  final int? dawarichId;
  final String? dawarichEndpoint;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String apiKey;
  final String theme;
  final UserSettingsDto userSettings;
  final bool admin;

  UserDto setDawarichEndpoint(String? endpoint) {
    return UserDto(
      id: id,
      dawarichId: dawarichId,
      dawarichEndpoint: endpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      apiKey: apiKey,
      theme: theme,
      userSettings: userSettings,
      admin: admin,
    );
  }

  UserDto({
    required this.id,
    required this.dawarichId,
    required this.dawarichEndpoint,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.apiKey,
    required this.theme,
    required this.userSettings,
    required this.admin
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
        id: 0,
        dawarichId: json["id"],
        dawarichEndpoint: "",
        email: json["email"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        apiKey: json["api_key"],
        theme: json["theme"],
        userSettings: UserSettingsDto.fromJson(json["settings"]),
        admin: json["admin"]
    );
  }

  factory UserDto.fromDatabase(UserTableData user, UserSettingsTableData userSettings) {
    return UserDto(
        id: user.id,
        dawarichId: user.dawarichId,
        dawarichEndpoint: user.dawarichEndpoint,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        apiKey: "",
        theme: user.theme,
        userSettings: UserSettingsDto.fromDatabase(userSettings),
        admin: user.admin
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "id": id,
  //     "dawarich"
  //     "email": email,
  //     "created_at": createdAt.toIso8601String(),
  //     "updated_at": updatedAt.toIso8601String(),
  //     "api_key": apiKey,
  //     "theme": theme,
  //     "settings": userSettings.toJson(),
  //     "admin": admin
  //   };
  // }

}