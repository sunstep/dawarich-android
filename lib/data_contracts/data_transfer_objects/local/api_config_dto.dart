
final class ApiConfigDTO {
  final String _host;
  String? _apiKey;

  String? get host => _host;
  String? get apiKey => _apiKey;

  ApiConfigDTO(this._host);

  void setApiKey(String apiKey) {
    _apiKey = apiKey;
  }

  ApiConfigDTO clear() {
    return ApiConfigDTO._empty();
  }

  ApiConfigDTO._empty() : _host = '', _apiKey = null;
  bool get isComplete => _host.isNotEmpty && _apiKey != null;

}
