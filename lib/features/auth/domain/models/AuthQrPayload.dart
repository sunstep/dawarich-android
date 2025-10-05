
import 'dart:convert';

final class AuthQrPayload {
  final String serverUrl;
  final String apiKey;

  AuthQrPayload({required this.serverUrl, required this.apiKey});

  factory AuthQrPayload.fromJsonString(String jsonString) {
    final obj = jsonDecode(jsonString);
    if (obj is! Map) {
      throw const FormatException('Invalid QR');
    }
    final url = obj['server_url'] as String?;
    final key = obj['api_key'] as String?;
    if (url == null || key == null) {
      throw const FormatException('Invalid QR');
    }
    return AuthQrPayload(serverUrl: url, apiKey: key);
  }

}