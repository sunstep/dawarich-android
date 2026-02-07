import 'package:dawarich/features/tracking/domain/enum/battery_state.dart';

abstract interface class IHardwareRepository {

  Future<String> getDeviceModel();

  Future<BatteryState> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String?> getWiFiStatus();
}
