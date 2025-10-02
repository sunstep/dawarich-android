import 'package:dawarich/core/database/drift/entities/point/point_geometry_table.dart';
import 'package:dawarich/core/database/drift/entities/point/point_properties_table.dart';
import 'package:drift/drift.dart';

class PointsTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get type => text()(); // "type" field in PointDto
  IntColumn get geometryId =>
      integer().references(PointGeometryTable, #id)(); // FK to geometry table
  IntColumn get propertiesId => integer()
      .references(PointPropertiesTable, #id)(); // FK to properties table

  TextColumn get deduplicationKey => text().nullable()();

  IntColumn get userId => integer()();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deduplicationKey}
  ];
}
