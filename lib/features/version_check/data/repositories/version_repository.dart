import 'package:dawarich/core/application/errors/failure.dart';
import 'package:dawarich/features/version_check/application/repository/version_repository_interfaces.dart';
import 'package:dawarich/features/version_check/data/sources/compat_rules_remote_data_source.dart';
import 'package:dawarich/features/version_check/data/sources/server_version_remote_data_source.dart';
import 'package:option_result/option_result.dart';

final class VersionRepository implements IVersionRepository {
  final IServerVersionRemoteDataSource _server;
  final ICompatRulesRemoteDataSource _rules;

  VersionRepository(this._server, this._rules);

  @override
  Future<Result<String, Failure>> getServerVersion() {
    return _server.getServerVersion();
  }

  @override
  Future<Result<String, Failure>> getCompatRules() {
    return _rules.getCompatRules();
  }
}