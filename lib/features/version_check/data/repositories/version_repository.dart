
import 'package:dawarich/core/network/dio_client.dart';
import 'package:dawarich/features/version_check/data_contracts/IVersionRepository.dart';
import 'package:option_result/option_result.dart';

final class VersionRepository implements IVersionRepository {

  final DioClient _apiClient;
  VersionRepository(this._apiClient);

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
}