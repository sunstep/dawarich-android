import 'package:dawarich/data/dawarich_api/config/api_config.dart';

abstract interface class IApiConfigManager {
  Future<void> load();
  void createConfig(String host);
  void setApiKey(String apiKey);
  ApiConfig? get apiConfig;
  Future<void> storeApiConfig();
  bool get isConfigured;
}

abstract interface class IApiConfigLogout {

  Future<void> clearConfiguration();
}