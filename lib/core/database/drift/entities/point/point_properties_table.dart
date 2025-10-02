import 'package:drift/drift.dart';

class PointPropertiesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get batteryState =>
      text()(); // Battery state (e.g., charging, full)
  RealColumn get batteryLevel =>
      real()(); // Battery level (percentage as a double)
  TextColumn get wifi => text()(); // Wi-Fi SSID
  DateTimeColumn get timestamp =>
      dateTime()(); // e.g. ISO8601 string or Unix epoch as text
  RealColumn get altitude => real()(); // Altitude in meters
  RealColumn get speed => real()(); // Speed in m/s
  RealColumn get horizontalAccuracy =>
      real()(); // Horizontal accuracy in meters
  RealColumn get verticalAccuracy => real()(); // Vertical accuracy in meters
  RealColumn get speedAccuracy => real()(); // Speed accuracy (m/s)
  RealColumn get course => real()(); // Course or bearing
  RealColumn get courseAccuracy => real()(); // Course accuracy
  TextColumn get trackId =>
      text().nullable()(); // Track identifier (e.g. UUID), may be null
  TextColumn get deviceId => text()(); // Device ID
}
