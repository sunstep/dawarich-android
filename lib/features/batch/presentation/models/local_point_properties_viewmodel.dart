import 'package:intl/intl.dart';

class LocalPointPropertiesViewModel {
  final String batteryState;
  final double batteryLevel;
  final String wifi;
  final String timestamp;
  String get formattedTimestamp {
    return DateFormat('dd MMM yyyy HH:mm:ss')
        .format(DateTime.parse(timestamp).toLocal());
  }

  final double horizontalAccuracy;
  final double verticalAccuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double course;
  final double courseAccuracy;
  final String? trackId;
  final String deviceId;

  LocalPointPropertiesViewModel({
    required this.batteryState,
    required this.batteryLevel,
    required this.wifi,
    required this.timestamp,
    required this.horizontalAccuracy,
    required this.verticalAccuracy,
    required this.altitude,
    required this.speed,
    required this.speedAccuracy,
    required this.course,
    required this.courseAccuracy,
    this.trackId,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'battery_state': batteryState,
      'battery_level': batteryLevel,
      'wifi': wifi,
      'timestamp': timestamp,
      'horizontal_accuracy': horizontalAccuracy,
      'vertical_accuracy': verticalAccuracy,
      'altitude': altitude,
      'speed': speed,
      'speed_accuracy': speedAccuracy,
      'course': course,
      'course_accuracy': courseAccuracy,
      'track_id': trackId,
      'device_id': deviceId,
    };
  }
}
