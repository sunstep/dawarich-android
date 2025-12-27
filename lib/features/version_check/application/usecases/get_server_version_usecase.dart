
import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:option_result/option_result.dart';
import 'package:pub_semver/pub_semver.dart';

final class GetServerVersionUseCase {

  final IVersionRepository _versionRepository;
  GetServerVersionUseCase(this._versionRepository);

  Future<Result<Version, Failure>> call() async {

    final Result<String, Failure> raw = await _versionRepository
        .getServerVersion();

    if (raw.isErr()) {
      final failure = raw.unwrapErr();
      return Err(failure.withContext(<String, Object?>{
        'where': 'GetServerVersionUseCase.call',
      }));
    }

    final String versionString = raw.unwrap();

    try {
      return Ok(Version.parse(versionString));
    } catch (e, s) {
      return Err(Failure(
        kind: FailureKind.validation,
        code: 'INVALID_SEMVER',
        message: 'Server version is not a valid semantic version.',
        cause: e,
        stack: s,
        context: <String, Object?>{'raw': versionString},
      ));
    }
  }
}