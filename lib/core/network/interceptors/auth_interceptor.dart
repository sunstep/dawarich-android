

import 'package:dawarich/core/network/api_config/api_config.dart';
import 'package:dawarich/core/network/api_config/api_config_manager_interfaces.dart';
import 'package:dio/dio.dart';

final class AuthInterceptor extends Interceptor {

  final IApiConfigManager _apiConfig;
  AuthInterceptor(this._apiConfig);


  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {

    final ApiConfig? config = _apiConfig.apiConfig;

    if (config == null) {
      handler.next(options);
      return;
    }

    options.baseUrl = config.host;

    if (config.isConfigured) {
      options.headers['Authorization'] = 'Bearer ${config.apiKey}';
    }

    handler.next(options);
  }


}