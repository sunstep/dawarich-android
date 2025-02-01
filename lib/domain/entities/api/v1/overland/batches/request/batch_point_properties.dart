
class BatchPointProperties {
  final String timestamp;
  final double altitude;
  final double speed;
  final double horizontalAccuracy;
  final double verticalAccuracy;
  final List<String> motion;
  final bool pauses;
  final String activity;
  final double desiredAccuracy;
  final double deferred;
  final String significantChange;
  final int locationsInPayload;
  final String deviceId;
  final String wifi;
  final String batteryState;
  final double batteryLevel;

  BatchPointProperties({
    required this.timestamp,
    required this.altitude,
    required this.speed,
    required this.horizontalAccuracy,
    required this.verticalAccuracy,
    required this.motion,
    required this.pauses,
    required this.activity,
    required this.desiredAccuracy,
    required this.deferred,
    required this.significantChange,
    required this.locationsInPayload,
    required this.deviceId,
    required this.wifi,
    required this.batteryState,
    required this.batteryLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'altitude': altitude,
      'speed': speed,
      'horizontal_accuracy': horizontalAccuracy,
      'vertical_accuracy': verticalAccuracy,
      'motion': motion,
      'pauses': pauses,
      'activity': activity,
      'desired_accuracy': desiredAccuracy,
      'deferred': deferred,
      'significant_change': significantChange,
      'locations_in_payload': locationsInPayload,
      'device_id': deviceId,
      'wifi': wifi,
      'battery_state': batteryState,
      'battery_level': batteryLevel,
    };
  }
}