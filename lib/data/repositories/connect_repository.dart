import 'dart:convert';
import 'dart:io';

import 'package:dawarich/domain/data_transfer_objects/local/api_config_dto.dart';
import 'package:dawarich/domain/interfaces/api_config.dart';
import 'package:dawarich/domain/interfaces/connect_repository.dart';
import 'package:http/http.dart' as http;
import 'package:dawarich/domain/data_transfer_objects/api/v1/health/response/health_dto.dart';
import 'package:flutter/cupertino.dart';

class ConnectRepository implements IConnectRepository {

  final IApiConfigSource _apiConfig;
  late ApiConfigDTO _apiInfo;

  ConnectRepository(this._apiConfig);

  Future<void> _initialize() async {
    await _apiConfig.initialize();
    ApiConfigDTO? apiInfo = _apiConfig.getApiConfig();

    if (!apiInfo.isConfigured()) {
      throw StateError("Cannot query points without a configured endpoint");
    }
    _apiInfo = apiInfo;
  }

  @override
  Future<bool> testHost() async {

    try {
      await _initialize();
      final Uri uri = Uri.parse("${_apiInfo.host}/api/v1/health");
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
  Future<bool> tryApiKey() async {

    await _initialize();
    final Uri uri = Uri.parse('${_apiInfo.host}/api/v1/points/?api_key=${_apiInfo.apiKey}&end_at=0000-01-01');
    final http.Response response = await http.get(uri);
    bool isValid = false;

    if (response.statusCode == 200) {
      isValid = true;
    }

    return isValid;
  }



}