
class AdditionalPointData {

  final int currentPointsInBatch;
  final String deviceId;
  final String wifi;
  final String batteryState;
  final double batteryLevel;

  AdditionalPointData({
    required this.currentPointsInBatch,
    required this.deviceId,
    required this.wifi,
    required this.batteryState,
    required this.batteryLevel
  });
}