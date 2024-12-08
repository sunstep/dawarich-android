import 'package:dawarich/domain/data_transfer_objects/api_config_dto.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiConfigSource implements IApiConfigSource {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiConfigDTO? apiConfig;



  @override
  bool isConfigured() => apiConfig != null;

  @override
  Future<void> initialize() async {
    String? host = await _secureStorage.read(key: 'host');
    String? apiKey = await _secureStorage.read(key: 'apiKey');

    apiConfig = ApiConfigDTO(host: host, apiKey: apiKey);
  }

  @override
  void setApiConfig(String host, String apiKey)  {
    apiConfig = ApiConfigDTO(host: host, apiKey: apiKey);
  }

  @override
  ApiConfigDTO? getApiConfig() {
      return apiConfig;
  }

  @override
  Future<void> storeApiConfig() async {
    await _secureStorage.write(key: 'host', value: apiConfig!.host);
    await _secureStorage.write(key: 'apiKey', value: apiConfig!.apiKey);
  }

  @override
  Future<bool> testConnection() async {

    final uri = Uri.parse('${apiConfig!.host}/api/v1/points/?api_key=${apiConfig!.apiKey}&end_at=0000-01-01');
    final response = await http.get(uri);
    bool isValid = false;

    if (response.statusCode == 200) {
      isValid = true;
    }

    return isValid;
  }

  @override
  Future<void> clearConfiguration() async {
    apiConfig = null;
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');
  }
}
