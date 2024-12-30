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

  Future<void> setApiKey(String apiKey) async {
    _source.setApiKey(apiKey);
  }

  Future<void> storeApiConfig() async {
    await _source.storeApiConfig();
  }

  Future<void> clearApiConfig() async {
    await _source.clearConfiguration();
  }

}