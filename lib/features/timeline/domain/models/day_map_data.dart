

import 'package:latlong2/latlong.dart';

final class DayMapData {

  final List<LatLng> points;
  final int? lastTimestampMs;

  DayMapData({
    this.points = const [],
    this.lastTimestampMs,
  });
}