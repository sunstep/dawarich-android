import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

abstract interface class IHardwareRepository {
  Future<Result<Position, String>> getPosition(
      LocationAccuracy locationAccuracy);
  Future<Option<Position>> getCachedPosition();

  Future<String> getDeviceModel();

  Future<String> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String> getWiFiStatus();
}
