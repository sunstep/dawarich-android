
import 'package:dawarich/features/auth/data/data_transfer_objects/users/user_settings_dto.dart';

final class UserDto {
  final int id; // local DB user id
  final int? remoteId; // server user id
  final String? dawarichEndpoint; // only locally stored
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String theme;
  final bool admin;
  final UserSettingsDto? settings;

  const UserDto({
    required this.id,
    this.remoteId,
    this.dawarichEndpoint,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    required this.theme,
    this.admin = false,
    this.settings,
  });

  UserDto copyWith({
    int? id,
    int? remoteId,
    String? dawarichEndpoint,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? apiKey,
    String? theme,
    bool? admin,
    UserSettingsDto? settings,
  }) {
    return UserDto(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      dawarichEndpoint: dawarichEndpoint ?? this.dawarichEndpoint,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      theme: theme ?? this.theme,
      admin: admin ?? this.admin,
      settings: settings ?? this.settings,
    );
  }

  /// Parse ONLY server shape (accepts { "user": {...} } or inner map).
  factory UserDto.fromRemote(Map<String, dynamic> json) {
    final src = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    return UserDto(
      id: 0, // placeholder for local until you assign/store it
      remoteId: src['id'] as int?,
      dawarichEndpoint: null, // never set from server
      email: (src['email'] as String?) ?? '',
      createdAt: _parseDate(src['created_at']) ?? DateTime.now(),
      updatedAt: _parseDate(src['updated_at']),
      theme: (src['theme'] as String?) ?? 'light',
      admin: (src['admin'] as bool?) ?? false,
      settings: (src['settings'] is Map<String, dynamic>)
          ? UserSettingsDto.fromJson(src['settings'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Merge remote fields into an existing local user WITHOUT losing local-only data.
  static UserDto mergeRemote(UserDto local, Map<String, dynamic> remoteJson) {
    final remote = UserDto.fromRemote(remoteJson);
    return local.copyWith(
      remoteId: remote.remoteId,
      email: remote.email,
      createdAt: remote.createdAt,
      updatedAt: remote.updatedAt,
      theme: remote.theme,
      admin: remote.admin,
      settings: remote.settings,
    );
  }

  UserDto withDawarichEndpoint(String? endpoint) {
    return UserDto(
      id: id,
      remoteId: remoteId,
      dawarichEndpoint: endpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      theme: theme,
      admin: admin,
      settings: settings,
    );
  }


  Map<String, dynamic> toLocalMap() => {
    'id': id,
    'remote_id': remoteId,
    'dawarich_endpoint': dawarichEndpoint,
    'email': email,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'theme': theme,
    'admin': admin ? 1 : 0,
    // serialize settings separately or as JSON:
    'settings_json': settings?.toJson(),
  };

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      try { return DateTime.parse(v); } catch (_) {}
    }
    return null;
  }
}