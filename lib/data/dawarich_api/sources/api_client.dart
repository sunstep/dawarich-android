import 'package:dio/dio.dart';

final class ApiClient {
  final Dio _dio;

  ApiClient(
      {required String baseUrl, required Future<String?> Function() getToken})
      : _dio = Dio(BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3))) {
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    }));

    assert(() {
      _dio.interceptors.add(LogInterceptor(
          request: true, requestBody: true, responseBody: true, error: true));
      return true;
    }());
  }

  Future<Response<T>> get<T>(String path, Map<String, dynamic>? queryParameters,
      Options? options, CancelToken? cancelToken) {
    return _dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }

  Future<Response<T>> post<T>(
      String path, Object data, Map<String, dynamic> queryParameters) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
      String path,
      Object? data,
      Map<String, dynamic> queryParameters,
      Options? options,
      CancelToken? cancelToken) {
    return _dio.delete(path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken);
  }
}
