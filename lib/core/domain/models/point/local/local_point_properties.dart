class LocalPointProperties {
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

  LocalPointProperties({
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

  factory LocalPointProperties.fromJson(Map<String, dynamic> json) {
    return LocalPointProperties(
      batteryState: json['battery_state'] as String,
      batteryLevel: (json['battery_level'] as num).toDouble(),
      wifi: json['wifi'] as String,
      timestamp: json['timestamp'] as String,
      horizontalAccuracy: (json['horizontal_accuracy'] as num).toDouble(),
      verticalAccuracy: (json['vertical_accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      speedAccuracy: (json['speed_accuracy'] as num).toDouble(),
      course: (json['course'] as num).toDouble(),
      courseAccuracy: (json['course_accuracy'] as num).toDouble(),
      trackId: json['track_id'] as String?, // nullable
      deviceId: json['device_id'] as String,
    );
  }
}
