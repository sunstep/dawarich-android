
final class VisitedCityFlatUiModel {
  final String country;
  final String city;
  final int points;
  final DateTime lastSeenAt;
  final Duration stayedFor;

  const VisitedCityFlatUiModel({
    required this.country,
    required this.city,
    required this.points,
    required this.lastSeenAt,
    required this.stayedFor,
  });
}