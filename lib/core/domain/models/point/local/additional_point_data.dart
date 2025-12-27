class AdditionalPointData {
  final String deviceId;
  final String? trackId;
  final String wifi;
  final String batteryState;
  final double batteryLevel;

  AdditionalPointData({
    required this.deviceId,
    this.trackId,
    required this.wifi,
    required this.batteryState,
    required this.batteryLevel
  });
}
