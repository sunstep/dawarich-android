import 'package:dawarich/data/sources/local/secure_storage/api_config_client.dart';

class ApiConfigService {

  final ApiConfigClient _source;
  ApiConfigService(this._source);

  Future<void> initialize() async {
    await _source.initialize();
  }

  bool isConfigured() {
    return _source.isConfigured();
  }

  Future<void> clearApiConfig() async {
    await _source.clearConfiguration();
  }

}