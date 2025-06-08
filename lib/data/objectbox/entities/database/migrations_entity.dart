
import 'package:objectbox/objectbox.dart';

@Entity()
final class MigrationsEntity {

  @Id(assignable: true)
  int id;

  int fromVersion;
  int toVersion;
  bool success;

  MigrationsEntity({
    required this.id,
    required this.fromVersion,
    required this.toVersion,
    required this.success
  });



}