
import 'package:objectbox/objectbox.dart';

@Entity()
final class PointPropertiesEntity {

  @Id()
  int id;                    // `INTEGER PRIMARY KEY AUTOINCREMENT`

  String batteryState;       // e.g. "charging", "full"
  double batteryLevel;       // percentage as a double
  String wifi;               // Wi-Fi SSID
  DateTime timestamp;          // kept as text (ISO8601 or epoch-string) for 1:1
  double altitude;           // in meters
  double speed;              // in m/s
  double horizontalAccuracy; // in meters
  double verticalAccuracy;   // in meters
  double speedAccuracy;      // in m/s
  double course;             // bearing
  double courseAccuracy;     // in degrees (or meters, depending on your data)
  String? trackId;           // nullable UUID (or null)
  String deviceId;           // device ID

  PointPropertiesEntity({
    this.id = 0,
    required this.batteryState,
    required this.batteryLevel,
    required this.wifi,
    required this.timestamp,
    required this.altitude,
    required this.speed,
    required this.horizontalAccuracy,
    required this.verticalAccuracy,
    required this.speedAccuracy,
    required this.course,
    required this.courseAccuracy,
    this.trackId,
    required this.deviceId,
  });
}