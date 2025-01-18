import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/data_contracts/interfaces/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ApiConfigSource implements IApiConfigSource {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiConfigDTO _apiConfig = ApiConfigDTO();

  @override
  bool isConfigured() => _apiConfig.host != null && _apiConfig.apiKey != null;

  @override
  Future<void> initialize() async {
    String? host = await _secureStorage.read(key: 'host');
    String? apiKey = await _secureStorage.read(key: 'apiKey');

    if (host != null && apiKey != null) {
      _apiConfig.setHost(host);
      _apiConfig.setApiKey(apiKey);
    }

  }

  @override
  ApiConfigDTO getApiConfig() => _apiConfig;


  @override
  Future<void> setHost(String host) async {

    _apiConfig.setHost(host);
  }

  @override
  Future<void> setApiKey(String apiKey) async {

    _apiConfig.setApiKey(apiKey);
  }

  @override
  Future<void> storeApiConfig() async {

    await _secureStorage.write(key: 'host', value: _apiConfig.host);
    await _secureStorage.write(key: 'apiKey', value: _apiConfig.apiKey);

  }

  @override
  Future<void> clearConfiguration() async {
    _apiConfig.clear();
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');
  }
}
