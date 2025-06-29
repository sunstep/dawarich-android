import 'package:objectbox/objectbox.dart';

@Entity()
final class PointGeometryEntity {
  @Id(assignable: true)
  int id;

  String type;

  String coordinates;

  PointGeometryEntity({
    this.id = 0,
    required this.type,
    required this.coordinates,
  });
}
