
import 'package:dawarich/interfaces/interfaces/api_config.dart';
import 'package:dawarich/interfaces/interfaces/connect_repository.dart';

class ConnectService {

  final IApiConfigSource _configSource;
  final IConnectRepository _connectRepository;

  ConnectService(this._connectRepository, this._configSource);

  Future<bool> testHost(String host) async {

    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    _configSource.setHost(fullUrl);
    _configSource.storeApiConfig();
    return _connectRepository.testHost();
  }

  Future<bool> tryApiKey(String apiKey) async {

    apiKey = apiKey.trim();
    _configSource.setApiKey(apiKey);
    _configSource.storeApiConfig();
    return _connectRepository.tryApiKey();

  }


  String _ensureProtocol(String host, {required bool isHttps}) {

    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }
}