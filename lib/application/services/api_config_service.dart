import 'package:dawarich/domain/interfaces/api_config.dart';

class ApiConfigService {

  final IApiConfigSource _source;
  ApiConfigService(this._source);

  Future<void> initialize() async {
    await _source.initialize();
  }

  bool isConfigured() {
    return _source.isConfigured();
  }

  Future<void> setApiConfig(String host, String apiKey) async {
    _source.setApiConfig(host, apiKey);
  }

  Future<bool> testConnection(String host, String apiKey) async {

    host = host.trim();
    apiKey = apiKey.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    _source.setApiConfig(fullUrl, apiKey);
    bool isValid = await _source.testConnection();


    if (isValid) {
      await _source.storeApiConfig();
    }


    return isValid;
  }

  String _ensureProtocol(String host, {required bool isHttps}) {

    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }

}