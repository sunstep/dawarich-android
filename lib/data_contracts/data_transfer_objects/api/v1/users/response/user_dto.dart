import 'package:dawarich/data/drift/database/sqlite_client.dart';

class UserDto {

  final int id;
  final int? remoteId;
  final String? dawarichEndpoint;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String apiKey;
  final String theme;
  final bool admin;

  UserDto withDawarichEndpoint(String? endpoint) {
    return UserDto(
      id: id,
      remoteId: remoteId,
      dawarichEndpoint: endpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      apiKey: apiKey,
      theme: theme,
      admin: admin,
    );
  }

  UserDto({
    required this.id,
    required this.remoteId,
    required this.dawarichEndpoint,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    required this.apiKey,
    required this.theme,
    required this.admin
  });
  
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
        id: 0,
        remoteId: json["id"],
        dawarichEndpoint: "",
        email: json["email"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        apiKey: json["api_key"],
        theme: json["theme"],
        admin: json["admin"]
    );
  }

  factory UserDto.fromDatabase(UserTableData user) {
    return UserDto(
        id: user.id,
        remoteId: user.dawarichId,
        dawarichEndpoint: user.dawarichEndpoint,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        apiKey: "",
        theme: user.theme,
        admin: user.admin
    );
  }


}