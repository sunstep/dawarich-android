class ApiConfig {
  final String host;
  String? apiKey;

  bool get hasHost => host.trim().isNotEmpty;
  bool get hasApiKey => apiKey != null && apiKey!.trim().isNotEmpty;
  bool get isFullyConfigured => hasHost && hasApiKey;

  ApiConfig({required this.host, this.apiKey});

  ApiConfig copyWith({String? host, String? apiKey}) {
    return ApiConfig(
      host: host ?? this.host,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
