import 'dart:convert';
import 'dart:io';

import 'package:dawarich/domain/data_transfer_objects/api_config_dto.dart';
import 'package:dawarich/domain/data_transfer_objects/health_dto.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

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
  ApiConfigDTO? getApiConfig() => _apiConfig;


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
  Future<bool> tryApiKey() async {

    final Uri uri = Uri.parse('${_apiConfig.host}/api/v1/points/?api_key=${_apiConfig.apiKey}&end_at=0000-01-01');
    final http.Response response = await http.get(uri);
    bool isValid = false;

    if (response.statusCode == 200) {
      isValid = true;
    }

    return isValid;
  }

  @override
  Future<bool> testHost() async {

    try {

      final Uri uri = Uri.parse("${_apiConfig.host}/api/v1/health");
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic resultBody = jsonDecode(response.body);
        final HealthDto health = HealthDto(resultBody);

        return health.status == "ok";
      } else {

        debugPrint("Host gave a status code other than 200: ${response.reasonPhrase}");
        return false;
      }
    } on SocketException catch (e) {

      debugPrint("SocketException: ${e.message}");
      return false;
    } catch (e) {

      debugPrint("Error in testHost: $e");
      return false;
    }
  }

  @override
  Future<void> clearConfiguration() async {
    _apiConfig.clear();
    await _secureStorage.delete(key: 'host');
    await _secureStorage.delete(key: 'apiKey');
  }
}
