import 'package:dawarich/features/tracking/domain/enum/battery_state.dart';
import 'package:dawarich/features/tracking/domain/enum/connectivity_kind.dart';

abstract interface class IHardwareRepository {

  Future<String> getDeviceModel();

  Future<BatteryState> getBatteryState();
  Future<double> getBatteryLevel();

  Future<String?> getWiFiStatus();

  /// Emits the current [ConnectivityKind] whenever the network state changes.
  Stream<ConnectivityKind> watchConnectivity();
}
