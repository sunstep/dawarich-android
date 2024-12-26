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


  Future<void> setApiHost(String host) async {
    _source.setHost(host);
  }

  Future<bool> testHost(String host) async {

    host = host.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    _source.setHost(fullUrl);
    return _source.testHost();
  }

  Future<bool> tryApiKey(String apiKey) async {

    apiKey = apiKey.trim();
    _source.setApiKey(apiKey);
    return _source.tryApiKey();

  }

  Future<void> storeApiConfig() async {
    await _source.storeApiConfig();
  }

  String _ensureProtocol(String host, {required bool isHttps}) {

    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }

    return host;
  }

}