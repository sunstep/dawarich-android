
final class User {

  int id;
  final int? remoteId;
  final String? dawarichHost;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String apiKey;
  final String theme;
  final bool admin;

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
      apiKey: apiKey,
      theme: theme,
      admin: admin,
    );
  }

  User(
      {required this.id,
        this.remoteId,
        this.dawarichHost,
        required this.email,
        required this.createdAt,
        required this.updatedAt,
        required this.apiKey,
        required this.theme,
        required this.admin});

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
        apiKey: json["api_key"],
        theme: json["theme"],
        admin: json["admin"]);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "remote_id": remoteId,
      "dawarich_host": dawarichHost,
      "email": email,
      "created_at": createdAt.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "api_key": apiKey,
      "theme": theme,
      "admin": admin,
    };
  }

}