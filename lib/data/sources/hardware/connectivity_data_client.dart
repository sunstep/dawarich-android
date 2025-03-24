import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityDataClient {

  Future<List<ConnectivityResult>> getWiFiStatus() async {
    return await Connectivity().checkConnectivity();
  }
}