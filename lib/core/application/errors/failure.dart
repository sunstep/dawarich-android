final class Failure {
  final FailureKind kind;     // category for logic (retry, UX, etc.)
  final String code;          // stable machine code: 'NETWORK_TIMEOUT', 'UNAUTHORIZED', ...
  final String message;       // safe, user-oriented text (localize at UI if you prefer)
  final Object? cause;        // original exception (not for display)
  final StackTrace? stackTrace;    // for logging
  final Map<String, Object?> context; // any extra key-values (e.g. endpoint, ids)

  const Failure({
    required this.kind,
    required this.code,
    required this.message,
    this.cause,
    this.stackTrace,
    this.context = const {},
  });

  /// Non-throwing clone with extra context (immutability friendly).
  Failure withContext(Map<String, Object?> extra) {
    return Failure(
      kind: kind,
      code: code,
      message: message,
      cause: cause,
      stackTrace: stackTrace,
      context: {...context, ...extra},
    );
  }

  @override
  String toString() {
    final codePart = code.isNotEmpty ? '[$code]' : '';
    return '$codePart $message';
  }
}

/// High-level categories (useful for retry/backoff/UI decisions).
enum FailureKind {
  /// Client is offline / DNS / timeout / TLS issues.
  network,

  /// 401/403 or invalid credentials/token.
  unauthorized,

  /// 404/410 or missing resource.
  notFound,

  /// 409, version mismatch, duplicate, constraint problems.
  conflict,

  /// Input validation errors (client-side or server-reported).
  validation,

  /// Local storage/DB/read-write problems.
  storage,

  /// Background service/OS integration problems (permissions, notifications).
  system,

  /// A catch-all for “didn’t fit elsewhere”.
  unknown,
}