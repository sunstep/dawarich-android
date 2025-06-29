import 'package:dawarich/core/network/configs/api_config.dart';

abstract interface class IApiConfigManager {
  Future<void> load();
  void createConfig(String host);
  void setApiKey(String apiKey);
  ApiConfig? get apiConfig;
  Future<void> storeApiConfig();
  bool get isConfigured;
}