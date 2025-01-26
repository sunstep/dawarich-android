
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WiFiDataClient {

  Future<String> getWiFiStatus() async {

    final List<ConnectivityResult> connectivityResults =
    await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      try {
        final NetworkInfo wifiInfo = NetworkInfo();
        final String? ssid = await wifiInfo.getWifiName();
        return ssid ?? "Unknown";
      } catch (e) {
        return "Unknown";
      }
    } else {
      return "No Wi-Fi";
    }
  }
}