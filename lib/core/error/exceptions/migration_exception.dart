final class MigrationException implements Exception {
  final String message;
  MigrationException(this.message);
  @override
  String toString() => 'MigrationException: $message';
}
