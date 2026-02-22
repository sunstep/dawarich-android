
final class CountriesQuery {

  final DateTime startAt;
  final DateTime endAt;

  const CountriesQuery({
    required this.startAt,
    required this.endAt,
  });

  bool get isValidRange => !endAt.isBefore(startAt);

  Map<String, dynamic> toUrlQuery() {
    return <String, dynamic>{
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
    };
  }
}