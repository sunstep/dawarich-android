
import 'package:dawarich/data/objectbox/entities/user/user_entity.dart';
import 'package:objectbox/objectbox.dart';

final class TrackEntity {

  @Id(assignable: true)
  int id;

  String trackId;

  @Property(type: PropertyType.date)
  DateTime startTimestamp;

  @Property(type: PropertyType.date)
  DateTime? endTimestamp;

  bool active;
  final ToOne<UserEntity> user = ToOne<UserEntity>();

  TrackEntity({
    this.id = 0,
    required this.trackId,
    required this.startTimestamp,
    this.endTimestamp,
    this.active = true
  });

}