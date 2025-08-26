import 'package:drift/drift.dart';

class PointGeometryTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get type => text()(); // "type" field in PointGeometryDto
  RealColumn get longitude => real().withDefault(const Constant(0.0))(); // Longitude
  RealColumn get latitude => real().withDefault(const Constant(0.0))(); // Latitude
}
