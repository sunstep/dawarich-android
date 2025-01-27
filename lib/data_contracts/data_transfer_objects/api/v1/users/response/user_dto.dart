
import 'package:dawarich/data_contracts/data_transfer_objects/api/v1/users/response/user_settings_dto.dart';

class UserDto {

  int id;
  String email;
  DateTime createdAt;
  DateTime updatedAt;
  String apiKey;
  String theme;
  UserSettingsDto userSettings;
  bool admin;

  UserDto({
    required this.id,
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
        id: json["id"],
        email: json["email"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        apiKey: json["api_key"],
        theme: json["theme"],
        userSettings: UserSettingsDto.fromJson(json["settings"]),
        admin: json["admin"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "api_key": apiKey,
      "theme": theme,
      "settings": userSettings.toJson(),
      "admin": admin
    };
  }

}