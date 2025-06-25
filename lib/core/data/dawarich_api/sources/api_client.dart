import 'package:dawarich/data_contracts/interfaces/api_config_manager_interfaces.dart';
import 'package:dio/dio.dart';

final class ApiClient {

  final Dio _dio;
  final IApiConfigManager _configManager;

  ApiClient(this._configManager)
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 20),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cfg = _configManager.apiConfig;

        if (cfg == null || cfg.host.isEmpty) {
          return handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'API host not configured',
          ));
        }

        options
          ..baseUrl   = cfg.host
          ..headers['Content-Type'] = Headers.jsonContentType;

        final key = cfg.apiKey;
        if (key != null && key.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $key';
        }

        return handler.next(options);
      },
    ));

    assert(() {
      _dio.interceptors.add(LogInterceptor(
          request: true, requestBody: true, responseBody: true, error: true));
      return true;
    }());
  }

  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken,
      Function(int, int)? onReceiveProgress}) {
    return _dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  }

  Future<Response<T>> post<T>(String path,
      {required Object data, required Map<String, dynamic> queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(String path, {
      Object? data,
      Map<String, dynamic>? queryParameters,
      Options? options,
      CancelToken? cancelToken }) {
    return _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  Future<Response<T>> head<T>(String path,
      {Object? data,
      required Map<String, dynamic> queryParameters,
      Options? options,
      CancelToken? cancelToken}) {
    return _dio.head(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}
