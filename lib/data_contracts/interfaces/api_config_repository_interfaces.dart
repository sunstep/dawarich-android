import 'package:dawarich/data/dawarich_api/config/api_config.dart';

abstract interface class IApiConfigRepository {
  Future<void> load();
  void createConfig(String host);
  void setApiKey(String apiKey);
  ApiConfig? get apiConfig;
  Future<void> storeApiConfig();
  Future<void> clearConfiguration();
  bool get isConfigured;
}
