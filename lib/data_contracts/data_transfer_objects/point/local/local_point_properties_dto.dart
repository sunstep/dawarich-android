class LocalPointPropertiesDto {
  final String batteryState;
  final double batteryLevel;
  final String wifi;
  final String timestamp;
  final double horizontalAccuracy;
  final double verticalAccuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double course;
  final double courseAccuracy;
  final String? trackId;
  final String deviceId;



  LocalPointPropertiesDto({
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

}