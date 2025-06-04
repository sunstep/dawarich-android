import 'package:dawarich/data/objectbox/entities/point/point_geometry_entity.dart';
import 'package:dawarich/data/objectbox/entities/point/point_properties_entity.dart';
import 'package:dawarich/data/objectbox/entities/user/user_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
final class PointEntity {

  @Id()
  int id;

  String type;
  final ToOne<PointGeometryEntity> geometry = ToOne<PointGeometryEntity>();
  final ToOne<PointPropertiesEntity> properties = ToOne<PointPropertiesEntity>();

  final ToOne<UserEntity> userId = ToOne<UserEntity>();
  bool isUploaded;

  PointEntity({
    this.id = 0,
    required this.type,
    this.isUploaded = false,
  });
}