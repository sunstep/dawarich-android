

import 'package:dawarich/features/version_check/data_contracts/IVersionRepository.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:pub_semver/pub_semver.dart';

final class VersionCheckService {

  static final Version _minimumRequiredVersion = Version(0, 30, 6);

  final IVersionRepository _versionRepository;
  VersionCheckService(this._versionRepository);

  Future<bool> isServerVersionSupported() async {
    final Result<String, String> versionResult = await _versionRepository
        .getServerVersion();

    if (versionResult.isErr()) {
      return false;
    }

    final String versionString = versionResult.unwrap();

    try {
      final serverVersion = Version.parse(versionString);
      return serverVersion >= _minimumRequiredVersion;
    } catch (e) {
      // Assume false if parsing fails
      if (kDebugMode) {
        debugPrint('[VersionCheck] Failed to parse server version: $e. String: $versionString');
      }
      return false;
    }
  }

  Future<Version> getServerVersion() async {
    final Result<String, String> versionResult = await _versionRepository
        .getServerVersion();

    if (versionResult.isErr()) {
      throw Exception('Failed to fetch server version: ${versionResult.unwrapErr()}');
    }

    final String versionString = versionResult.unwrap();

    try {
      return Version.parse(versionString);
    } catch (e) {
      throw Exception('Invalid server version format: $versionString');
    }
  }


}