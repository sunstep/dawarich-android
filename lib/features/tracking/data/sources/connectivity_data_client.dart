import 'package:connectivity_plus/connectivity_plus.dart';

final class ConnectivityDataClient {
  Future<List<ConnectivityResult>> getWiFiStatus() async {
    return await Connectivity().checkConnectivity();
  }
}
