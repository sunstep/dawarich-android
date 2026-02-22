import 'package:dawarich/core/network/configs/api_config.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class ApiConfigManager implements IApiConfigManager, IApiConfigLogout {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  ApiConfig? _apiConfig;
  ApiConfigManager();
  static const _iOS    = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  @override
  Future<void> load() async {

    if (kDebugMode) {
      debugPrint('ApiConfigManager: Attempting to read api config from encrypted storage.');
    }

    final String? host = await _secureStorage.read(
        key: 'host',
        iOptions: _iOS
    );

    final String? apiKey = await _secureStorage.read(
        key: 'apiKey',
        iOptions: _iOS
    );

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

    await _secureStorage.write(
        key: 'host',
        value: cfg.host,
        iOptions: _iOS
    );
    await _secureStorage.write(
        key: 'apiKey',
        value: cfg.apiKey,
        iOptions: _iOS
    );
  }

  @override
  Future<void> clearConfiguration() async {
    await _secureStorage.delete(
        key: 'host',
        iOptions: _iOS
    );
    await _secureStorage.delete(
        key: 'apiKey',
        iOptions: _iOS
    );

    _apiConfig = null;
  }

  @override
  bool get isConfigured {
    final ApiConfig? configCopy = _apiConfig;
    return configCopy != null && configCopy.isConfigured;
  }
}
