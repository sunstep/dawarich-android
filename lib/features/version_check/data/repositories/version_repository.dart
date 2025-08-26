
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/version_check/data_contracts/version_repository_interfaces.dart';
import 'package:dio/dio.dart';
import 'package:option_result/option_result.dart';

final class VersionRepository implements IVersionRepository {

  final DioClient _apiClient;
  VersionRepository(this._apiClient);

  Future<String> getCompatUrl() async {
    final sha = await _getCompatCommitSha(); // commit sha, not blob sha
    return 'https://raw.githubusercontent.com/sunstep/dawarich-android-feedback/$sha/compat.json'; // In the future this will be same repository as the code it self.
  }

  @override
  Future<Result<String, String>> getServerVersion() async {
    try {
      final response = await _apiClient.head('/api/v1/health');
      if (response.statusCode == 200) {
        final version = response.headers.value('x-dawarich-version');
        if (version != null && version.isNotEmpty) {
          return Ok(version);
        } else {
          return const Err('Version header not found');
        }
      } else {
        return const Err('Failed to fetch version');
      }
    } catch (e) {
      return Err('Error fetching version: $e');
    }
  }

  /// Fetches the commit SHA for the compat-test.json file from the main branch.
  /// This is to prevent retrieving cached versions of the file.
  Future<String> _getCompatCommitSha() async {

    try {
      final resp = await _apiClient.get(
        "https://api.github.com/repos/sunstep/dawarich-android-feedback/commits?path=compat.json&sha=main&per_page=1", // In the future this will be same repository as the code it self.
        options: Options(
          extra: {'skipAuth': true},
          headers: {
            'Accept': 'application/vnd.github.v3+json',
            'User-Agent': 'Dawarich/1.0',
          },
        ),
      );

      if (resp.statusCode == 200 && resp.data is List && (resp.data as List).isNotEmpty) {
        final first = (resp.data as List).first as Map<String, dynamic>;
        final sha = first['sha'] as String?;
        if (sha != null && sha.isNotEmpty) return sha;
        throw Exception('Commit SHA missing');
      }

      throw Exception('Unexpected response: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Error fetching compatibility SHA: $e');
    }
  }

  @override
  Future<Result<String, String>> getCompatRules() async {

    try {

      final String compatUrl = await getCompatUrl();
      final response = await _apiClient.get(
        compatUrl
      );

      if (response.statusCode == 200) {
        final compatRules = response.data as String;
        if (compatRules.isNotEmpty) {
          return Ok(compatRules);
        } else {
          return const Err('Compatibility rules are empty');
        }
      } else {
        return const Err('Failed to fetch compatibility rules');
      }
    } catch (e) {
      return Err('Error fetching compatibility rules: $e');
    }
  }
}