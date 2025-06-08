
import 'package:objectbox/objectbox.dart';

@Entity()
class UserEntity {
  @Id(assignable: true)
  int id;

  int? remoteId;

  String? dawarichHost;

  String? email;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime? updatedAt;

  String theme;

  bool admin;

  UserEntity({
    this.id = 0,
    this.remoteId,
    this.dawarichHost,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    required this.theme,
    required this.admin,
  });
}