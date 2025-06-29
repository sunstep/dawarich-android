import 'package:dawarich/core/network/api_config/api_config.dart';
import 'package:dawarich/core/network/api_config/api_config_manager_interfaces.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class ApiConfigManager implements IApiConfigManager, IApiConfigLogout {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  ApiConfig? _apiConfig;
  ApiConfigManager();

  @override
  Future<void> load() async {
    final host = await _secureStorage.read(key: 'host');
    final apiKey = await _secureStorage.read(key: 'apiKey');

    if (host != null && apiKey != null) {
      ApiConfig config = ApiConfig(host: host, apiKey: apiKey);

      _apiConfig = config;
    }
  }

  @override
  ApiConfig? get apiConfig => _apiConfig;

  @override
  void createConfig(String host) {
    _apiConfig = ApiConfig(host: host.trim());
  }

  @override
  void setApiKey(String apiKey) {
    ApiConfig? configCopy = _apiConfig;

    if (configCopy == null) {
      throw Exception('Cannot set API key before setting host');
    }

    configCopy.setApiKey(apiKey.trim());

    _apiConfig = configCopy;
  }

  @override
  Future<void> storeApiConfig() async {
    final ApiConfig? cfg = _apiConfig;

    if (cfg == null || !cfg.isConfigured) {
      throw Exception('Cannot store incomplete ApiConfigDTO');
    }

    await _secureStorage.write(key: 'host', value: cfg.host);
    await _secureStorage.write(key: 'apiKey', value: cfg.apiKey);
  }

  @override
  Future<void> clearConfiguration() async {
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');

    _apiConfig = null;
  }

  @override
  bool get isConfigured {
    final ApiConfig? configCopy = _apiConfig;
    return configCopy != null && configCopy.isConfigured;
  }
}
