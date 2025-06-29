

import 'package:dio/dio.dart';

final class ErrorInterceptor extends Interceptor {


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final statusCode = response?.statusCode;

    final friendlyMessage = switch (err.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.receiveTimeout => 'Server took too long to respond.',
      DioExceptionType.sendTimeout => 'Request took too long to send.',
      DioExceptionType.badCertificate => 'Bad SSL certificate.',
      DioExceptionType.badResponse => _handleBadResponse(statusCode),
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.connectionError => 'Unable to connect to server.',
      DioExceptionType.unknown => 'Unexpected error occurred.',
    };

    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: friendlyMessage,
      type: err.type,
    );

    handler.next(newError);
  }

  String _handleBadResponse(int? statusCode) {
    return switch (statusCode) {
      400 => 'Bad request (400).',
      401 => 'Unauthorized (401). Please log in again.',
      403 => 'Forbidden (403). You don’t have access.',
      404 => 'Resource not found (404).',
      500 => 'Server error (500). Please try again later.',
      int code when code != null && code >= 500 => 'Server error ($code).',
      _ => 'Unexpected server response.',
    };
  }
}