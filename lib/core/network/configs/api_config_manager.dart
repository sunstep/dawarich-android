import 'package:dawarich/core/network/configs/api_config.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dawarich/core/shell/drawer/i_api_config_logout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class ApiConfigManager implements IApiConfigManager, IApiConfigLogout {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  ApiConfig? _apiConfig;
  ApiConfigManager();
  static const _aEnc   = AndroidOptions(encryptedSharedPreferences: true);
  static const _aPlain = AndroidOptions(encryptedSharedPreferences: false);
  static const _iOS    = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  @override
  Future<void> load() async {

    if (kDebugMode) {
      debugPrint('ApiConfigManager: Attempting to read api config from encrypted storage.');
    }

    final String? host = await _secureStorage.read(
        key: 'host',
        aOptions: _aEnc,
        iOptions: _iOS
    );
    final String? apiKey = await _secureStorage.read(
        key: 'apiKey',
        aOptions: _aEnc,
        iOptions: _iOS
    );

    if (host == null || apiKey == null) {

      if (kDebugMode) {
        debugPrint('ApiConfigManager: Attempting to read legacy unencrypted storage.');
      }

      final String? legacyHost = await _secureStorage.read(
          key: 'host',
          aOptions: _aPlain,
          iOptions: _iOS
      );
      final String? legacyApiKey = await _secureStorage.read(
          key: 'apiKey',
          aOptions: _aPlain,
          iOptions: _iOS
      );
      if (legacyHost != null && legacyApiKey != null) {
        if (kDebugMode) {
          debugPrint('ApiConfigManager: legacy config found, migrating to encrypted storage.');
        }
        await _secureStorage.write(
            key: 'host',
            value: legacyHost,
            aOptions: _aEnc,
            iOptions: _iOS
        );
        await _secureStorage.write(
            key: 'apiKey',
            value: legacyApiKey,
            aOptions: _aEnc,
            iOptions: _iOS
        );
        await _secureStorage.delete(
            key: 'host',
            aOptions: _aPlain,
            iOptions: _iOS
        );
        await _secureStorage.delete(
            key: 'apiKey',
            aOptions: _aPlain,
            iOptions: _iOS
        );
      }
    }

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
        aOptions: _aEnc,
        iOptions: _iOS
    );
    await _secureStorage.write(
        key: 'apiKey',
        value: cfg.apiKey,
        aOptions: _aEnc,
        iOptions: _iOS
    );
  }

  @override
  Future<void> clearConfiguration() async {
    await _secureStorage.delete(
        key: 'host',
        aOptions: _aEnc,
        iOptions: _iOS
    );
    await _secureStorage.delete(
        key: 'apiKey',
        aOptions: _aEnc,
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
