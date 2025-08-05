

import 'package:option_result/option_result.dart';

abstract interface class IVersionRepository {

  /// Retrieves the current version of the Dawarich server.
  Future<Result<String, String>> getServerVersion();
}