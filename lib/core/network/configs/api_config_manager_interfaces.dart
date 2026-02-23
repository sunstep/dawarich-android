import 'package:dawarich/core/network/configs/api_config.dart';

abstract interface class IApiConfigManager {
  void createConfig(String host);
  void setApiKey(String apiKey);
  Future<void> storeApiConfig();
  Future<void> load();

  ApiConfig? get apiConfig;
  bool get hasHost;
  bool get isConfigured;
}