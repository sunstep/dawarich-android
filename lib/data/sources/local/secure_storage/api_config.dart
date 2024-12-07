import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiConfigSource implements IApiConfigSource {

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? _host;
  String? _apiKey;

  String? get host => _host;
  String? get apiKey => _apiKey;

  @override
  bool isConfigured() => _host != null && _apiKey != null;

  @override
  Future<void> initialize() async {
    _host = await _secureStorage.read(key: 'host');
    _apiKey = await _secureStorage.read(key: 'apiKey');
  }

  @override
  void setApiConfig(String host, String apiKey)  {
    _host = host;
    _apiKey = apiKey;
  }

  @override
  Future<void> storeApiConfig() async {
    await _secureStorage.write(key: 'host', value: host);
    await _secureStorage.write(key: 'apiKey', value: apiKey);
  }

  @override
  Future<bool> testConnection() async {

    final uri = Uri.parse('$host/api/v1/points/?api_key=$apiKey&end_at=0000-01-01');
    final response = await http.get(uri);
    bool isValid = false;

    if (response.statusCode == 200) {
      isValid = true;
    }

    return isValid;
  }

  @override
  Future<void> clearConfiguration() async {
    _host = null;
    _apiKey = null;
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');
  }
}
