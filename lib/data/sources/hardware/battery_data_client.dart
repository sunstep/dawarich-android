import 'package:battery_plus/battery_plus.dart';

class BatteryDataSource {

  late Battery _battery;

  BatteryDataSource() {
    _battery = Battery();
  }

  Future<String> getBatteryState() async {

    BatteryState state = await _battery.batteryState;
    String value = state.toString().split(".")[1];

    if (value == "connectedNotCharging") {
      value = "full";
    } else if (value == "discharging") {
      value = "unplugged";
    }

    return value;
  }

  Future<double> getBatteryLevel() async => await _battery.batteryLevel / 100;


}