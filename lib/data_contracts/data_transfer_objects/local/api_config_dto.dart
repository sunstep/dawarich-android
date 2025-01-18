
class ApiConfigDTO {
  String? _host;
  String? _apiKey;

  String? get host => _host;
  String? get apiKey => _apiKey;

  void setHost(String host) {
    _host = host;
  }

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  bool isConfigured() => host != null;

  void clear() {
    _host = null;
    _apiKey = null;
  }

}
