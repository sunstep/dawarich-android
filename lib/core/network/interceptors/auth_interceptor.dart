import 'package:dawarich/core/network/configs/api_config.dart';
import 'package:dawarich/core/network/configs/api_config_manager_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final class AuthInterceptor extends Interceptor {

  final IApiConfigManager _apiConfig;
  AuthInterceptor(this._apiConfig);

  bool _isAbsolute(String path) =>
      path.startsWith('http://') || path.startsWith('https://');


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    final ApiConfig? config = _apiConfig.apiConfig;

    if (config == null) {
      if (kDebugMode) {
        debugPrint('AuthInterceptor: No ApiConfig found, skipping auth attachment.');
      }

      handler.next(options);
      return;
    }

    if (!_isAbsolute(options.path) && (options.baseUrl.isEmpty || options.baseUrl == '/')) {
      options.baseUrl = config.host; // e.g. https://dawarich.app
    }

    final skipAuthFlag = options.extra['skipAuth'] == true;

    final requestUri = _isAbsolute(options.path)
        ? Uri.parse(options.path)
        : Uri.parse(options.baseUrl).resolve(options.path);

    final apiHost = Uri.parse(config.host).host;
    final isApiHost = requestUri.host == apiHost;


    final shouldAttachAuth = !skipAuthFlag && isApiHost && config.isConfigured;

    if (shouldAttachAuth) {
      options.headers['Authorization'] = 'Bearer ${config.apiKey}';
    } else {
      options.headers.remove('Authorization');
    }

    handler.next(options);
  }


}