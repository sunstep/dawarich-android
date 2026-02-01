

import 'dart:convert';

import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';


/// Use case: decide if the app may proceed given server version + compat rules.
/// - Debug builds: run check but allow bypass on failure (logs errors)
/// - Release builds: enforce check (block on failure)
/// - Network/parse errors: fail open (OK)
/// - Rules can *block* (Err with message)
/// - Rules can restrict server with `allowServer` range (Err with message)
final class ServerVersionCompatibilityUseCase {

  final IVersionRepository _versionRepository;
  ServerVersionCompatibilityUseCase(this._versionRepository);

  Future<Result<(), Failure>> call() async {
    final result = await _performCheck();

    // In debug mode, log failures but allow bypass
    if (kDebugMode && result.isErr()) {
      final failure = result.unwrapErr();
      debugPrint('[VersionCheck] ⚠️ Check failed but bypassing in debug mode:');
      debugPrint('[VersionCheck]   Code: ${failure.code}');
      debugPrint('[VersionCheck]   Message: ${failure.message}');
      return const Ok(());
    }

    return result;
  }

  /// Performs the actual version compatibility check.
  Future<Result<(), Failure>> _performCheck() async {

    final Result<String, Failure> versionResult = await _versionRepository.getServerVersion();
    if (versionResult.isErr()) {
      return const Ok(()); // fail open if we can't get server version
    }

    final String versionString = versionResult.unwrap();

    final serverVersion = Version.parse(versionString);

    final Result<String, Failure> compatabilityRulesResult =
    await _versionRepository.getCompatRules();

    if (compatabilityRulesResult.isErr()) {
      if (kDebugMode) {
        debugPrint(
            '[VersionCheck] Failed to fetch compatibility rules: ${compatabilityRulesResult
                .unwrapErr()}');
      }
      return const Ok(()); // fail open if we can't fetch rules
    }

    final String rulesJson = compatabilityRulesResult.unwrap();

    // Version from pubspec.yaml
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Version appVersion = Version.parse(packageInfo.version);

    final Map<String, dynamic>? map = _tryDecodeMap(rulesJson);

    if (map == null) {
      if (kDebugMode) {
        debugPrint('[VersionCheck] compat.json parse failed, failing open');
      }
      return const Ok(());
    }

    final List<dynamic> rulesList = (map['rules'] as List?) ?? const [];
    final Map<String, dynamic> defaultRule = (map['default'] as Map<
        String,
        dynamic>?) ?? const {};

    final List<Map<String, dynamic>> typedRules =
    rulesList.whereType<Map<String, dynamic>>().toList();

    Map<String, dynamic>? matchedRule;
    int i = 0;
    while (i < typedRules.length && matchedRule == null) {
      final Map<String, dynamic> item = typedRules[i];

      final Object? clientRangeObj = item['client'];
      final String? clientRangeStr = clientRangeObj is String
          ? clientRangeObj
          : null;

      if (clientRangeStr != null && clientRangeStr.isNotEmpty) {
        final VersionConstraint? clientConstraint = _tryParseConstraint(
            clientRangeStr);
        final bool isAllowed =
            clientConstraint != null && clientConstraint.allows(appVersion);

        if (isAllowed) {
          matchedRule = item;
        }
      }

      i = i + 1;
    }

    final Map<String, dynamic> rule = matchedRule ?? defaultRule;

    // Blocked?
    final bool blocked = (rule['blocked'] as bool?) ?? false;
    if (blocked) {
      if (kDebugMode) {
        debugPrint('[VersionCheck] Blocked by rule: ${rule['message'] ??
            '(no message)'}');
      }
      final String message =
          (rule['message'] as String?) ??
              'This app version is no longer supported.';

      return Err(Failure(
        kind: FailureKind.validation,
        code: 'APP_VERSION_BLOCKED',
        message: message,
        context: <String, Object?>{
          'appVersion': appVersion.toString(),
          'serverVersion': serverVersion.toString(),
        },
      ));
    }

    // If rule has allowServer, enforce it; otherwise allow.
    final String? allowServerStr = rule['allowServer'] as String?;
    if (allowServerStr == null || allowServerStr
        .trim()
        .isEmpty) {
      return const Ok(());
    }

    final VersionConstraint? serverConstraint = _tryParseConstraint(
        allowServerStr);
    if (serverConstraint == null) {
      return Ok(());
    }

    final bool serverOk = serverConstraint.allows(serverVersion);

    if (!serverOk) {
      final String message =
          (rule['message'] as String?) ??
              'This server version is not supported.';

      return Err(Failure(
        kind: FailureKind.validation,
        code: 'SERVER_VERSION_NOT_ALLOWED',
        message: message,
        context: <String, Object?>{
          'serverVersion': serverVersion.toString(),
          'allowServer': allowServerStr,
        },
      ));
    }

    return const Ok(());
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  VersionConstraint? _tryParseConstraint(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      return VersionConstraint.parse(raw);
    } catch (_) {
      return null;
    }
  }

}

