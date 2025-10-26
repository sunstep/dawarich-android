

import 'dart:convert';

import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:flutter/foundation.dart';
import 'package:option_result/option_result.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

final class VersionCheckService {

  final IVersionRepository _versionRepository;
  VersionCheckService(this._versionRepository);

  Future<Result<(), String>> isServerVersionSupported() async {

    if (kDebugMode) {
      return const Ok(()); // Skip version check in debug mode
    }

    final Result<String, String> versionResult = await _versionRepository.getServerVersion();
    if (versionResult.isErr()) {
      return const Ok(()); // fail open if we can't get server version
    }

    final String versionString = versionResult.unwrap();

    try {
      final serverVersion = Version.parse(versionString);

      final Result<String, String> compatabilityRulesResult =
      await _versionRepository.getCompatRules();

      if (compatabilityRulesResult.isErr()) {
        if (kDebugMode) {
          debugPrint('[VersionCheck] Failed to fetch compatibility rules: ${compatabilityRulesResult.unwrapErr()}');
        }
        return const Ok(()); // fail open if we can't fetch rules
      }

      final String rulesJson = compatabilityRulesResult.unwrap();

      // App (client) version from pubspec.yaml
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final Version appVersion = Version.parse(packageInfo.version);

      final Map<String, dynamic> map = jsonDecode(rulesJson) as Map<String, dynamic>;
      final List<dynamic> rulesList = (map['rules'] as List?) ?? const [];
      final Map<String, dynamic> defaultRule = (map['default'] as Map<String, dynamic>?) ?? const {};

      Map<String, dynamic>? matched;
      for (final r in rulesList) {
        final rule = r as Map<String, dynamic>;
        final clientRangeStr = rule['client'] as String?;
        if (clientRangeStr == null) continue;

        try {
          final clientRange = VersionConstraint.parse(clientRangeStr);
          if (clientRange.allows(appVersion)) {
            matched = rule;
            break;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[VersionCheck] Bad client range "$clientRangeStr": $e');
          }
        }
      }

      final Map<String, dynamic> rule = matched ?? defaultRule;

      // Blocked?
      final bool blocked = (rule['blocked'] as bool?) ?? false;
      if (blocked) {
        if (kDebugMode) {
          debugPrint('[VersionCheck] Blocked by rule: ${rule['message'] ?? '(no message)'}');
        }
        return Err(rule['message'] as String? ?? 'This app version is no longer supported.');
      }

      // If rule has allowServer, enforce it; otherwise allow.
      final String? allowServerStr = rule['allowServer'] as String?;
      if (allowServerStr == null || allowServerStr.trim().isEmpty) {
        return const Ok(()); // no server constraint => allowed
      }

      try {
        final serverConstraint = VersionConstraint.parse(allowServerStr);
        final ok = serverConstraint.allows(serverVersion);
        if (!ok) {
          return Err(rule['message'] as String? ?? 'This server version is not supported.');
        }
        return const Ok(());
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[VersionCheck] Bad allowServer range "$allowServerStr": $e');
        }
        return const Ok(()); // fail open on parse error
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
            '[VersionCheck] Failed to parse server version: $e. String: $versionString');
      }
      return const Ok(());
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