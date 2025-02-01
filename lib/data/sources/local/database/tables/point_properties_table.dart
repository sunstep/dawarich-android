import 'package:drift/drift.dart';

class PointPropertiesTable extends Table {
  IntColumn get id => integer().autoIncrement()(); // Primary Key
  TextColumn get timestamp => text()(); // Timestamp field
  RealColumn get altitude => real()(); // Altitude in meters
  RealColumn get speed => real()(); // Speed in m/s
  RealColumn get horizontalAccuracy => real()(); // Horizontal accuracy in meters
  RealColumn get verticalAccuracy => real()(); // Vertical accuracy in meters
  TextColumn get motion => text()(); // Motion stored as a JSON string
  BoolColumn get pauses => boolean()(); // Pauses (true/false)
  TextColumn get activity => text()(); // Activity description
  RealColumn get desiredAccuracy => real()(); // Desired accuracy in meters
  RealColumn get deferred => real()(); // Deferred distance in meters
  TextColumn get significantChange => text()(); // Significant change field
  IntColumn get locationsInPayload => integer()(); // Number of locations in payload
  TextColumn get deviceId => text()(); // Device ID
  TextColumn get wifi => text()(); // Wi-Fi SSID
  TextColumn get batteryState => text()(); // Battery state
  RealColumn get batteryLevel => real()(); // Battery level (percentage)
}
