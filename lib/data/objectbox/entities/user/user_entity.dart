
import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id()
  int id;

  int? dawarichId;

  String? dawarichEndpoint;

  String? email;

  DateTime createdAt;

  DateTime? updatedAt;

  String theme;

  bool admin;

  UserEntity({
    this.id = 0,
    this.dawarichId,
    this.dawarichEndpoint,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    required this.theme,
    required this.admin,
  });
}