class LocalPointProperties {
  final String batteryState;
  final double batteryLevel;
  final String wifi;
  final DateTime recordTimestamp;
  final DateTime providerTimestamp;
  final double horizontalAccuracy;
  final double verticalAccuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double course;
  final double courseAccuracy;
  final String? trackId;
  final String deviceId;

  LocalPointProperties({
    required this.batteryState,
    required this.batteryLevel,
    required this.wifi,
    required this.recordTimestamp,
    required this.providerTimestamp,
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
}
