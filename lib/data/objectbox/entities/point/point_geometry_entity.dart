
import 'package:objectbox/objectbox.dart';

@Entity()
final class PointGeometryEntity {

  @Id()
  int id;

  String type;

  String coordinates;

  PointGeometryEntity({
    this.id = 0,
    required this.type,
    required this.coordinates,
  });


}