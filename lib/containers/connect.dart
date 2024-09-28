import 'package:flutter/material.dart';
import 'package:dawarich/helpers/endpoint.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:async';


class ConnectContainer {

  final BuildContext _context;
  ConnectContainer(this._context);

  String? validateInputs(String? input) {

    if (input == null || input.isEmpty){
      return "This field is required";
    }

    return null;
  }

  Future<bool> validateCredentials(String host, String apiKey) async {

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

    EndpointResult endpoint = Provider.of<EndpointResult>(_context, listen: false);
    await endpoint.setInfo(host, apiKey);
    await endpoint.getInfo();

  }
}