
final class User {

  int id;
  final int? remoteId;
  final String? dawarichHost;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String theme;
  final bool admin;
  // final UserSettings settings;

  void addUserId(int userId) {
    id = userId;
  }

  User withDawarichEndpoint(String? endpoint) {
    return User(
      id: id,
      remoteId: remoteId,
      dawarichHost: endpoint,
      email: email,
      createdAt: createdAt,
      updatedAt: updatedAt,
      theme: theme,
      admin: admin,
      // settings: settings
    );
  }

  User({
        required this.id,
        this.remoteId,
        this.dawarichHost,
        required this.email,
        required this.createdAt,
        required this.updatedAt,
        required this.theme,
        required this.admin,
        // required this.settings
      });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"],
        remoteId: json["remote_id"] is int ? json["remote_id"] : null,
        dawarichHost: json["dawarich_host"] is String ? json["dawarich_host"] : null,
        email: json["email"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        theme: json["theme"],
        admin: json["admin"],
        // settings: json["settings"]
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "remote_id": remoteId,
      "dawarich_host": dawarichHost,
      "email": email,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "theme": theme,
      "admin": admin,
      // "settings": settings
    };
  }

}