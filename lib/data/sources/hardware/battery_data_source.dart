import 'package:battery_plus/battery_plus.dart';

class BatteryDataSource {

  late Battery _battery;

  BatteryDataSource() {
    _battery = Battery();
  }

  Future<String> getBatteryState() async {

    BatteryState state = await _battery.batteryState;
    return state.toString().split(".")[1];
  }

  Future<int> getBatteryLevel() async => await _battery.batteryLevel;


}