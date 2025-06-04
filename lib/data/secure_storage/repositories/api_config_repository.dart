import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config_repository_interfaces.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final class ApiConfigRepository implements IApiConfigRepository {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  ApiConfigDTO? _apiConfig;


  ApiConfigRepository();

  @override
  Future<void> initialize() async {

    final host = await _secureStorage.read(key: 'host');
    final apiKey = await _secureStorage.read(key: 'apiKey');
    if (host != null && apiKey != null) {
      ApiConfigDTO config = ApiConfigDTO(host);
      config.setApiKey(apiKey);

      _apiConfig = config;
    }
  }

  @override
  ApiConfigDTO? getApiConfig() => _apiConfig;

  @override
  void setHost(String host) {
    _apiConfig = ApiConfigDTO(host.trim());
  }

  @override
  void setApiKey(String apiKey) {

    if (_apiConfig == null) {
      throw Exception('Cannot set API key before setting host');
    }
    _apiConfig!.setApiKey(apiKey.trim());
  }

  @override
  Future<void> storeApiConfig() async {

    final ApiConfigDTO? cfg = _apiConfig;
    if (cfg == null || !cfg.isComplete) {
      throw Exception('Cannot store incomplete ApiConfigDTO');
    }
    await _secureStorage.write(key: 'host', value: cfg.host);
    await _secureStorage.write(key: 'apiKey', value: cfg.apiKey!);
  }

  @override
  Future<void> clearConfiguration() async {
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');

    _apiConfig = null;
  }

  @override
  bool isConfigured() => _apiConfig != null && _apiConfig!.isComplete;

}