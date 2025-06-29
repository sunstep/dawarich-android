class AdditionalPointDataDto {
  final int currentPointsInBatch;
  final String deviceId;
  final String wifi;
  final String batteryState;
  final double batteryLevel;

  AdditionalPointDataDto(this.currentPointsInBatch, this.deviceId, this.wifi,
      this.batteryState, this.batteryLevel);
}
