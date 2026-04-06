import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:option_result/option_result.dart';

abstract interface class ICompatRulesRemoteDataSource {
  Future<Result<String, Failure>> getCompatRules();
}

final class CompatRulesRemoteDataSource
    implements ICompatRulesRemoteDataSource {
  final DioClient _apiClient;
  CompatRulesRemoteDataSource(this._apiClient);

  @override
  Future<Result<String, Failure>> getCompatRules() async {
    final shaRes = await _getCompatCommitSha();
    if (shaRes.isErr()) {
      return Err(shaRes.unwrapErr().withContext({'where': 'getCompatRules'}));
    }

    final sha = shaRes.unwrap();
    final url =
        'https://raw.githubusercontent.com/sunstep/dawarich-android/$sha/compat.json';

    try {
      final resp = await _apiClient.get(
        url,
        options: Options(
          extra: {'skipAuth': true},
          headers: {
            'Accept': 'text/plain',
            'User-Agent': 'Dawarich/1.0',
          },
          responseType: ResponseType.plain,
        ),
      );

      if (resp.statusCode == 200) {
        final body = resp.data is String ? resp.data as String : resp.data?.toString() ?? '';
        if (body.isNotEmpty) {
          return Ok(body);
        }

        return Err(Failure(
          kind: FailureKind.validation,
          code: 'EMPTY_BODY',
          message: 'Compatibility rules are empty',
          context: {'url': url},
        ));
      }

      return Err(Failure(
        kind: FailureKind.network,
        code: 'HTTP_${resp.statusCode ?? 0}',
        message: 'Failed to fetch compatibility rules',
        context: {'url': url, 'method': 'GET'},
      ));
    } on DioException catch (e, s) {
      return Err(Failure(
        kind: FailureKind.network,
        code: 'COMPAT_RULES_REQUEST_FAILED',
        message: 'Error fetching compatibility rules',
        cause: e,
        stackTrace: s,
        context: {'url': url, 'method': 'GET'},
      ));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching compatibility rules',
        cause: e,
        stackTrace: s,
        context: {'url': url, 'method': 'GET'},
      ));
    }
  }

  Future<Result<String, Failure>> _getCompatCommitSha() async {
    const ghUrl =
        'https://api.github.com/repos/sunstep/dawarich-android/commits'
        '?path=compat.json&sha=main&per_page=1';

    try {
      final resp = await _apiClient.get(
        ghUrl,
        options: Options(
          extra: {'skipAuth': true},
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Dawarich/1.0',
          },
        ),
      );

      if (resp.statusCode == 200 && resp.data is List && (resp.data as List).isNotEmpty) {
        final first = (resp.data as List).first;

        if (first is Map<String, dynamic>) {
          final sha = first['sha'] as String?;
          if (sha != null && sha.isNotEmpty) {
            return Ok(sha);
          }
        }

        return Err(Failure(
          kind: FailureKind.validation,
          code: 'COMMIT_SHA_MISSING',
          message: 'Commit SHA missing in GitHub response',
          context: {'endpoint': ghUrl},
        ));
      }

      return Err(Failure(
        kind: FailureKind.network,
        code: 'HTTP_${resp.statusCode ?? 0}',
        message: 'Unexpected response from GitHub',
        context: {'endpoint': ghUrl, 'method': 'GET'},
      ));
    } on DioException catch (e, s) {
      return Err(Failure(
        kind: FailureKind.network,
        code: 'COMPAT_SHA_REQUEST_FAILED',
        message: 'Error fetching compatibility SHA',
        cause: e,
        stackTrace: s,
        context: {'endpoint': ghUrl, 'method': 'GET'},
      ));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching compatibility SHA',
        cause: e,
        stackTrace: s,
        context: {'endpoint': ghUrl, 'method': 'GET'},
      ));
    }
  }
}