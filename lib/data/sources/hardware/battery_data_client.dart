import 'package:battery_plus/battery_plus.dart';

final class BatteryDataClient {

  late Battery _battery;

  BatteryDataClient() {
    _battery = Battery();
  }

  Future<String> getBatteryState() async {

    BatteryState state = await _battery.batteryState;
    String value = state.toString().split(".")[1];

    return value;
  }

  Future<int> getBatteryLevel() async => await _battery.batteryLevel;


}