import 'package:option_result/result.dart';

abstract class MigrationStep {

  /// The version this migration step is from.
  int get fromVersion;

  /// The version this migration step is to.
  int get toVersion;

  /// Only needed for non-schema migrations.
  Future<bool> get isPending;

  /// Runs the migration step.
  Future<Result<(), String>> migrate();
}
