
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

abstract interface class IHardwareRepository {

  Future<Result<Position, String>> getPosition({required LocationAccuracy locationAccuracy, required int minimumDistance});
  Future<Option<Position>> getCachedPosition();

  Future<String> getDeviceModel();

  Future<String> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String> getWiFiStatus();

}