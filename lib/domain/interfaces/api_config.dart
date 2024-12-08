
import 'package:dawarich/domain/data_transfer_objects/api_config_dto.dart';

abstract interface class IApiConfigSource {

  Future<void> initialize();
  void setApiConfig(String host, String apiKey);
  ApiConfigDTO? getApiConfig();
  Future<void> storeApiConfig();
  Future<bool> testConnection();
  Future<void> clearConfiguration();
  bool isConfigured();

}