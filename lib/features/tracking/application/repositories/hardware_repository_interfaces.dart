abstract interface class IHardwareRepository {

  Future<String> getDeviceModel();

  Future<String> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String> getWiFiStatus();
}
