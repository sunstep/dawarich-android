
import 'package:dawarich/domain/data_transfer_objects/api_config_dto.dart';

abstract interface class IApiConfigSource {

  Future<void> initialize();
  Future<void> setHost(String host);
  Future<void> setApiKey(String apiKey);
  ApiConfigDTO? getApiConfig();
  Future<void> storeApiConfig();
  Future<bool> testHost();
  Future<bool> tryApiKey();
  Future<void> clearConfiguration();
  bool isConfigured();

}