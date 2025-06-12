class ApiConfig {
  final String host;
  String? apiKey;
  bool get isConfigured => apiKey != null;

  ApiConfig({required this.host, this.apiKey});

  void setApiKey(String apiKey) {
    this.apiKey = apiKey;
  }
}
