import 'package:drift/drift.dart';

class PointGeometryTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get type => text()(); // "type" field in PointGeometryDto
  TextColumn get coordinates => text()(); // Coordinates stored as a JSON string
  RealColumn get longitude => real()(); // Longitude
  RealColumn get latitude => real()(); // Latitude
}
