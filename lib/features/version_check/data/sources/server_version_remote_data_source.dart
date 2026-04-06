import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:option_result/option_result.dart';

abstract interface class IServerVersionRemoteDataSource {
  Future<Result<String, Failure>> getServerVersion();
}

final class ServerVersionRemoteDataSource
    implements IServerVersionRemoteDataSource {
  final DioClient _apiClient;
  ServerVersionRemoteDataSource(this._apiClient);

  @override
  Future<Result<String, Failure>> getServerVersion() async {
    try {
      final resp = await _apiClient.head('/api/v1/health');

      if (resp.statusCode == 200) {
        final version = resp.headers.value('x-dawarich-version');
        if (version != null && version.isNotEmpty) {
          return Ok(version);
        }

        return Err(Failure(
          kind: FailureKind.validation,
          code: 'HEADER_MISSING',
          message: 'Version header not found',
          context: {'header': 'x-dawarich-version'},
        ));
      }

      return Err(Failure(
        kind: FailureKind.network,
        code: 'HTTP_${resp.statusCode ?? 0}',
        message: 'Failed to fetch version',
        context: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    } on DioException catch (e, s) {
      return Err(Failure(
        kind: FailureKind.network,
        code: 'SERVER_VERSION_REQUEST_FAILED',
        message: 'Error fetching server version',
        cause: e,
        stackTrace: s,
        context: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching server version',
        cause: e,
        stackTrace: s,
        context: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    }
  }
}