
import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:option_result/option_result.dart';

final class VersionRepository implements IVersionRepository {

  final DioClient _apiClient;
  VersionRepository(this._apiClient);

  Future<Result<String, Failure>> getCompatUrl() async {
    final shaRes = await _getCompatCommitSha();
    if (shaRes.isErr()) {
      return Err(shaRes.unwrapErr().withContext({'where': 'getCompatUrl'}));
    }

    final sha = shaRes.unwrap();
    final url =
        'https://raw.githubusercontent.com/sunstep/dawarich-android-feedback/$sha/compat.json';
    return Ok(url);
  }

  @override
  Future<Result<String, Failure>> getServerVersion() async {
    try {
      final resp = await _apiClient.head('/api/v1/health');

      if (resp.statusCode == 200) {
        final version = resp.headers.value('x-dawarich-version');
        if (version != null && version.isNotEmpty) {
          return Ok(version);
        }

        return Err(
          Failure(
            kind: FailureKind.validation,
            code: 'HEADER_MISSING',
            message: 'Version header not found',
            context: {'header': 'x-dawarich-version'},
          ),
        );
      }

      return Err(_failureFromStatus(
        'Failed to fetch version',
        status: resp.statusCode ?? 0,
        ctx: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    } on DioException catch (e, s) {
      return Err(_mapDioToFailure(
        e,
        s,
        code: 'SERVER_VERSION_REQUEST_FAILED',
        friendly: 'Error fetching server version',
        ctx: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching server version',
        cause: e,
        stack: s,
        context: {'endpoint': '/api/v1/health', 'method': 'HEAD'},
      ));
    }
  }

  /// Fetches the commit SHA for the compat-test.json file from the main branch.
  /// This is to prevent retrieving cached versions of the file.
  Future<Result<String, Failure>> _getCompatCommitSha() async {

    const ghUrl =
        'https://api.github.com/repos/sunstep/dawarich-android-feedback/commits'
        '?path=compat.json&sha=main&per_page=1'; // In the future this will be same repository as the code it self.

    try {
      final resp = await _apiClient.get(ghUrl,
        options: Options(
          extra: {'skipAuth': true},
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Dawarich/1.0',
          },
        ),
      );

      if (resp.statusCode == 200 && resp.data is List &&
          (resp.data as List).isNotEmpty) {
        final first = (resp.data as List).first;

        if (first is Map<String, dynamic>) {
          final sha = first['sha'] as String?;

          if (sha != null && sha.isNotEmpty) {
            return Ok(sha);
          }

          return Err(Failure(
            kind: FailureKind.validation,
            code: 'COMMIT_SHA_MISSING',
            message: 'Commit SHA missing in GitHub response',
            context: {'response_first': first},
          ));
        }

        return Err(Failure(
          kind: FailureKind.validation,
          code: 'UNEXPECTED_PAYLOAD',
          message: 'Unexpected GitHub payload shape',
          context: {'type': first.runtimeType.toString()},
        ));
      }

      return Err(_failureFromStatus(
        'Unexpected response from GitHub',
        status: resp.statusCode ?? 0,
        ctx: {'endpoint': ghUrl, 'method': 'GET'},
      ));
    } on DioException catch (e, s) {
      return Err(
        _mapDioToFailure(e, s,
            code: 'COMPAT_RULES_REQUEST_FAILED',
            friendly: 'Error fetching compatibility rules',
            ctx: {'url': ghUrl, 'method': 'GET'}
        )
      );
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching compatibility SHA',
        cause: e,
        stack: s,
        context: {'endpoint': ghUrl, 'method': 'GET'}
      ));
    }
  }

  @override
  Future<Result<String, Failure>> getCompatRules() async {
    final urlRes = await getCompatUrl();
    if (urlRes.isErr()) {
      return Err(urlRes.unwrapErr().withContext({'where': 'getCompatRules'}));
    }

    final url = urlRes.unwrap();

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

      return Err(_failureFromStatus(
        'Failed to fetch compatibility rules',
        status: resp.statusCode ?? 0,
        ctx: {'url': url, 'method': 'GET'},
      ));
    } on DioException catch (e, s) {
      return Err(_mapDioToFailure(
        e,
        s,
        code: 'COMPAT_RULES_REQUEST_FAILED',
        friendly: 'Error fetching compatibility rules',
        ctx: {'url': url, 'method': 'GET'},
      ));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.unknown,
        code: 'UNEXPECTED_ERROR',
        message: 'Unexpected error while fetching compatibility rules',
        cause: e,
        stack: s,
        context: {'url': url, 'method': 'GET'},
      ));
    }
  }

  Failure _failureFromStatus(
      String friendly, {
        required int status,
        Map<String, Object?> ctx = const {},
      }) {
    final FailureKind kind;
    final String code;

    if (status == 401 || status == 403) {
      kind = FailureKind.unauthorized;
      code = 'UNAUTHORIZED';
    } else if (status == 404) {
      kind = FailureKind.notFound;
      code = 'NOT_FOUND';
    } else if (status == 409) {
      kind = FailureKind.conflict;
      code = 'CONFLICT';
    } else if (status == 429) {
      kind = FailureKind.network; // rate-limit is network-ish from UX/retry pov
      code = 'RATE_LIMITED';
    } else if (status >= 500 && status < 600) {
      kind = FailureKind.network; // backend unavailable
      code = 'SERVER_UNAVAILABLE';
    } else {
      kind = FailureKind.unknown;
      code = 'HTTP_${status.toString()}';
    }

    return Failure(
      kind: kind,
      code: code,
      message: friendly,
      context: {'status': status, ...ctx},
    );
  }

  Failure _mapDioToFailure(
      DioException e,
      StackTrace s, {
        required String code,
        required String friendly,
        Map<String, Object?> ctx = const {},
      }) {
    FailureKind kind = FailureKind.unknown;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      kind = FailureKind.network;
    } else if (e.type == DioExceptionType.badResponse) {
      final status = e.response?.statusCode ?? 0;
      // Reuse the HTTP status mapper for consistency
      return _failureFromStatus(
        friendly,
        status: status,
        ctx: {...ctx, 'dio': e.type.toString()},
      ).withContext({'code': code});
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      kind = FailureKind.network;
    }

    return Failure(
      kind: kind,
      code: code,
      message: friendly,
      cause: e,
      stack: s,
      context: {
        ...ctx,
        'dio': e.type.toString(),
        'status': e.response?.statusCode,
      },
    );
  }
}