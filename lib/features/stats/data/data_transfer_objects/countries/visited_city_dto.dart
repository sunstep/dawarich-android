
class VisitedCityDto {
  final String city;
  final int points;
  final int timestamp;
  final int stayedFor;

  const VisitedCityDto({
    required this.city,
    required this.points,
    required this.timestamp,
    required this.stayedFor
  });

  factory VisitedCityDto.fromJson(Map<String, dynamic> json) {
    final cityRaw = json['city'];
    final pointsRaw = json['points'];
    final timestampRaw = json['timestamp'];
    final stayedForRaw = json['stayed_for'];

    return VisitedCityDto(
      city: cityRaw is String ? cityRaw : '',
      points: pointsRaw is int ? pointsRaw : 0,
      timestamp: timestampRaw is int ? timestampRaw : 0,
      stayedFor: stayedForRaw is int ? stayedForRaw : 0,
    );
  }

}