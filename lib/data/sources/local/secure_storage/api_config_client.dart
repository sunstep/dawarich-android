import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final class ApiConfigClient {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ApiConfigDTO _apiConfig = ApiConfigDTO();

  bool isConfigured() => _apiConfig.host != null && _apiConfig.apiKey != null;

  Future<void> initialize() async {
    String? host = await _secureStorage.read(key: 'host');
    String? apiKey = await _secureStorage.read(key: 'apiKey');

    if (host != null && apiKey != null) {
      _apiConfig.setHost(host);
      _apiConfig.setApiKey(apiKey);
    }

  }

  ApiConfigDTO getApiConfig() => _apiConfig;


  Future<void> setHost(String host) async {

    _apiConfig.setHost(host);
  }

  Future<void> setApiKey(String apiKey) async {

    _apiConfig.setApiKey(apiKey);
  }

  Future<void> storeApiConfig() async {

    await _secureStorage.write(key: 'host', value: _apiConfig.host);
    await _secureStorage.write(key: 'apiKey', value: _apiConfig.apiKey);

  }

  Future<void> clearConfiguration() async {

    _apiConfig.clear();

    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');
  }
}
