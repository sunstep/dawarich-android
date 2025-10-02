import 'dart:math';
import 'package:latlong2/latlong.dart';

class PointPair {
  final LatLng A;
  final LatLng B;

  const PointPair(this.A, this.B);

  bool _isAntiPodal() {
    double latA = degToRadian(A.latitude);
    double lngA = degToRadian(A.longitude);
    double latB = degToRadian(B.latitude);
    double lngB = degToRadian(B.longitude);
    const double threshold = 1e-10;

    double dSigma =
        acos(sin(latA) * sin(latB) + cos(latA) * cos(latB) * cos(lngB - lngA));

    return ((pi - dSigma).abs() < threshold);
  }

  double calculateDistance() {
    const Distance distanceVincenty = DistanceVincenty();
    const Distance distanceHaversine = DistanceHaversine();

    if (_isAntiPodal()) {
      return distanceHaversine.as(LengthUnit.Meter, A, B);
    }

    return distanceVincenty.as(LengthUnit.Meter, A, B);
  }
}
