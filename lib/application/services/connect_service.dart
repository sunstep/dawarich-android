import 'package:dawarich/data_contracts/interfaces/connect_repository_interfaces.dart';

class ConnectService {

  final IConnectRepository _connectRepository;

  ConnectService(this._connectRepository);

  Future<bool> testHost(String host) async {

    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    return _connectRepository.testHost(fullUrl);
  }

  Future<bool> tryApiKey(String apiKey) async {

    apiKey = apiKey.trim();
    bool success = await _connectRepository.tryApiKey(apiKey);

    return success;
  }


  String _ensureProtocol(String host, {required bool isHttps}) {

    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }
}