import 'package:dawarich/data_contracts/data_transfer_objects/local/api_config_dto.dart';

abstract interface class IApiConfigRepository {
  Future<void> initialize();
  void setHost(String host);
  void setApiKey(String apiKey);
  ApiConfigDTO? getApiConfig();
  Future<void> storeApiConfig();
  Future<void> clearConfiguration();
  bool isConfigured();
}
