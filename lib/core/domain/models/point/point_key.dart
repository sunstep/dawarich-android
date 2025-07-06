
final class PointKey {
  final int    userId;
  final int    epochSec;
  final double lon;
  final double lat;

  PointKey({
    required this.userId,
    required this.epochSec,
    required this.lon,
    required this.lat,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PointKey &&
              other.userId   == userId &&
              other.epochSec == epochSec &&
              other.lon      == lon &&
              other.lat      == lat;

  @override
  int get hashCode => Object.hash(userId, epochSec, lon, lat);
}