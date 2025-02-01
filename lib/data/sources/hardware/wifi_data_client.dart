import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WiFiDataClient {

  Future<String> getWiFiStatus() async {
    final List<ConnectivityResult> connectivityResults =
    await Connectivity().checkConnectivity();

    if (connectivityResults.contains(ConnectivityResult.wifi)) {
      try {
        final NetworkInfo wifiInfo = NetworkInfo();
        final String? rawSSID = await wifiInfo.getWifiName();

        // Clean the output by removing outer quotes.
        final String ssid = (rawSSID != null &&
            rawSSID.startsWith('"') &&
            rawSSID.endsWith('"'))
            ? rawSSID.substring(1, rawSSID.length - 1)
            : rawSSID ?? "Unknown";
        return ssid;
      } catch (e) {
        return "Unknown";
      }
    } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
      return "Mobile Data";
    } else {
      return "No Connectivity";
    }
  }
}