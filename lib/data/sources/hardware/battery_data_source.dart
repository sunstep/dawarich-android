import 'package:battery_plus/battery_plus.dart';

class BatteryDataSource {

  late Battery _battery;

  BatteryDataSource() {
    _battery = Battery();
  }

  Future<String> getBatteryState() async => _battery.batteryState.toString();

  Future<int> getBatteryLevel() async {
    return _battery.batteryLevel;
  }

}