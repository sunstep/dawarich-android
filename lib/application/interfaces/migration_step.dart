import 'package:option_result/result.dart';

abstract class MigrationStep {
  int get fromVersion;
  int get toVersion;

  Future<bool> get isPending;
  Future<Result<(), String>> migrate();
}
