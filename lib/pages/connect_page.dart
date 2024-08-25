import 'package:flutter/material.dart';
import 'package:dawarich/widgets/appbar.dart';
import 'package:dawarich/pages/map_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;


class ConnectionPage extends StatefulWidget {

  const ConnectionPage({super.key});

  @override
  ConnectionPageState createState() => ConnectionPageState();
}

class ConnectionPageState extends State<ConnectionPage> {

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _apiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValidating = false;
  String? _credentialsError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Connect to Dawarich", fontSize: 35),
      body: _pageContent(),
    );
  }

  Widget _pageContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (value) => _validateInputs(value),
              forceErrorText: _credentialsError,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiController,
              decoration: const InputDecoration(
                labelText: 'Api Key',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.visiblePassword,
              validator: (value) => _validateInputs(value),
              forceErrorText: _credentialsError,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _connect,
              child: _isValidating
                  ? const CircularProgressIndicator()
                  : const Text('Connect'),
            ),
          ],
        ),
      )
    );
  }

  String? _validateInputs(String? input) {

    if (input == null || input.isEmpty){
      return "This field is required";
    }

    return null;
  }

  void _connect() async {

    if (!_formKey.currentState!.validate()){
      return;
    }

    setState(() {
      _isValidating = true;
      _credentialsError = null;
    });

    bool isValid = await _validateCredentials(_hostController.text, _apiController.text);

    setState(() {

      if (isValid) {
        _credentialsError = null;
        Navigator.push(context, 
        MaterialPageRoute(builder: (context) => const MapPage()));
      } else {

        _credentialsError = 'Invalid host or API key';
      }

      _isValidating = false;
    });
  }

  Future<bool> _validateCredentials(String host, String apiKey) async {

    host = host.trim();
    apiKey = apiKey.trim();

    if (host.endsWith("/")) {
      host = host.substring(0, host.length - 1);
    }

    String fullUrl = _ensureProtocol(host, isHttps: true);
    bool isValid = await _tryValidate(fullUrl, apiKey);

    if (!isValid) {
      fullUrl = _ensureProtocol(host, isHttps: false);
      isValid = await _tryValidate(fullUrl, apiKey);
    }

    return isValid;
  }

  String _ensureProtocol(String host, {required bool isHttps}) {
    if (!host.startsWith("http://") && !host.startsWith("https://")) {
      return isHttps ? "https://$host" : "http://$host";
    }
    return host;
  }

  Future<bool> _tryValidate(String host, String apiKey) async {
    final uri = Uri.parse('$host/api/v1/points/?api_key=$apiKey&end_at=0000-01-01');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      await _storeConnection(host, apiKey);
      return true;
    }
    return false;
  }

  Future<void> _storeConnection(String host, String apiKey) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    await storage.write(key: "host", value: host);
    await storage.write(key: "api_key", value: apiKey);
  }
}
