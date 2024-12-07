
abstract interface class IApiConfigSource {

  Future<void> initialize();
  void setApiConfig(String host, String apiKey);
  Future<void> storeApiConfig();
  Future<bool> testConnection();
  Future<void> clearConfiguration();
  bool isConfigured();
}