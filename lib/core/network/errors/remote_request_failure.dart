

sealed class RemoteRequestFailure {

  final String userMessage;           // what to show to user
  final String? technicalMessage;     // for logs/bug reports
  final int? statusCode;              // HTTP code if any
  final String? traceId;              // from server e.g. x-request-id
  final String? requestId;            // idem
  final bool isRetryable;             // can we backoff/retry?
  final Duration? retryAfter;         // parsed from Retry-After
  final Map<String, Object?>? extra;  // validation map etc.
  final FailureOrigin origin;         // origin of the failure

  const RemoteRequestFailure({
    required this.userMessage,
    this.technicalMessage,
    this.statusCode,
    this.traceId,
    this.requestId,
    this.isRetryable = false,
    this.retryAfter,
    this.extra,
    this.origin = FailureOrigin.unknown,
  });

  @override
  String toString() {
    final code = statusCode != null ? ' $statusCode' : '';
    final retry = retryAfter != null ? ' retryAfter=${retryAfter!.inSeconds}s' : '';
    final trace = traceId != null ? ' traceId=$traceId' : '';
    final req   = requestId != null ? ' requestId=$requestId' : '';
    return '[${origin.name.toUpperCase()}$code] $userMessage$retry$trace$req';
  }

  /// Verbose diagnostics for debug screens / bug reports
  String get debugString {
    final b = StringBuffer()
      ..writeln('origin        : ${origin.name}')
      ..writeln('statusCode    : ${statusCode ?? '-'}')
      ..writeln('userMessage   : $userMessage')
      ..writeln('technical     : ${technicalMessage ?? '-'}')
      ..writeln('retryAfter    : ${retryAfter?.inSeconds ?? '-'}s')
      ..writeln('traceId       : ${traceId ?? '-'}')
      ..writeln('requestId     : ${requestId ?? '-'}')
      ..writeln('extra         : ${extra ?? '-'}');
    return b.toString();
  }

}

enum FailureOrigin { network, tls, timeout, auth, permission, notFound, conflict, validation, rateLimit, server, protocol, unknown }

final class OfflineFailure extends RemoteRequestFailure {
  const OfflineFailure({String? technical})
      : super(
    userMessage: 'No internet connection.',
    technicalMessage: technical,
    isRetryable: true,
    origin: FailureOrigin.network,
  );
}

final class TimeoutFailure extends RemoteRequestFailure {
  const TimeoutFailure({String? technical})
      : super(
    userMessage: 'The server took too long to respond.',
    technicalMessage: technical,
    isRetryable: true,
    origin: FailureOrigin.timeout,
  );
}

final class TlsFailure extends RemoteRequestFailure {
  const TlsFailure({String? technical})
      : super(
    userMessage: 'Secure connection failed.',
    technicalMessage: technical,
    origin: FailureOrigin.tls,
  );
}

final class UnauthorizedFailure extends RemoteRequestFailure {
  const UnauthorizedFailure({String? technical})
      : super(
    userMessage: 'Please sign in again.',
    technicalMessage: technical,
    statusCode: 401,
    origin: FailureOrigin.auth,
  );
}

final class ForbiddenFailure extends RemoteRequestFailure {
  const ForbiddenFailure({String? technical})
      : super(
    userMessage: 'You do not have permission to perform this action.',
    technicalMessage: technical,
    statusCode: 403,
    origin: FailureOrigin.permission,
  );
}

final class NotFoundFailure extends RemoteRequestFailure {
  const NotFoundFailure({String? technical})
      : super(
    userMessage: 'The requested resource was not found.',
    technicalMessage: technical,
    statusCode: 404,
    origin: FailureOrigin.notFound,
  );
}

final class ConflictFailure extends RemoteRequestFailure {
  const ConflictFailure({String? technical})
      : super(
    userMessage: 'The request conflicts with current state.',
    technicalMessage: technical,
    statusCode: 409,
    origin: FailureOrigin.conflict,
  );
}

final class ValidationFailure extends RemoteRequestFailure {
  ValidationFailure({
    required Map<String, List<String>> fieldErrors,
    String? serverMessage,
    super.statusCode,
  }) : super(
    userMessage: serverMessage ?? 'Please fix the highlighted fields.',
    technicalMessage: 'Validation failed',
    extra: {
      'fieldErrors': Map<String, List<String>>.unmodifiable(
        fieldErrors.map(
              (k, v) => MapEntry(k, List<String>.unmodifiable(v)),
        ),
      ),
    },
    origin: FailureOrigin.validation,
  );

  Map<String, List<String>> get fieldErrors =>
      (extra?['fieldErrors'] as Map<String, List<String>>?) ?? const {};
}

final class RateLimitFailure extends RemoteRequestFailure {
  const RateLimitFailure({super.retryAfter})
      : super(
    userMessage: 'Too many requests. Please try again later.',
    technicalMessage: '429 Too Many Requests',
    statusCode: 429,
    isRetryable: true,
    origin: FailureOrigin.rateLimit,
  );
}

final class ServerFailure extends RemoteRequestFailure {
  const ServerFailure({super.statusCode, String? serverMessage})
      : super(
    userMessage: serverMessage ?? 'Server error. Please try again later.',
    technicalMessage: '5xx error',
    isRetryable: true,
    origin: FailureOrigin.server,
  );
}

final class UnexpectedFailure extends RemoteRequestFailure {
  const UnexpectedFailure({String? technical, super.statusCode})
      : super(
    userMessage: 'Something went wrong.',
    technicalMessage: technical,
    origin: FailureOrigin.unknown,
  );
}