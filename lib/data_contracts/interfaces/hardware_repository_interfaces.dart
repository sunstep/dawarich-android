import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

abstract interface class IHardwareRepository {

  Future<Result<Position, String>> getPosition(LocationAccuracy locationAccuracy);
  Future<Option<Position>> getCachedPosition();
  Stream<Result<Position, String>> getPositionStream({
    required LocationAccuracy accuracy,
    required int minimumDistance,
  });

  Future<String> getDeviceModel();

  Future<String> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String> getWiFiStatus();

}