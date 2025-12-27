
import 'dart:io';

import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/core/domain/models/point/point_pair.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option_result.dart';


final class PointValidator {

  Future<Result<(), String>> validatePoint(LocalPoint point) async {

    final Future<bool> isNewerF = _isPointNewerThanLastPoint(point);
    final Future<bool> isDistanceF = _isPointDistanceGreaterThanPreference(point);
    final Future<bool> isAccurateF = _isPointAccurateEnough(point);

    final results = await Future.wait([
      isNewerF,
      isDistanceF,
      isAccurateF
    ]);

    final bool isNewer = results[0];
    final bool isDistance = results[1];
    final bool isAccurate = results[2];

    if (!isNewer) {
      return const Err("Point is not newer than the last stored point.");
    }

    if (!isDistance) {
      return const Err("Point is not sufficiently distant from the last point.");
    }

    if (!isAccurate) {
      return const Err("Point does not meet the required accuracy.");
    }

    return const Ok(());
  }

  Future<bool> _isPointNewerThanLastPoint(LocalPoint point) async {
    // TODO (Future update):
    // Currently this check always passes because `_constructPoint`
    // guarantees monotonically increasing timestamps by falling back
    // to DateTime.now() if the GPS timestamp is stale.
    //
    // When we add support for last-known points (e.g. from Geolocator or
    // other apps), we need a smarter duplicate heuristic instead of just
    // comparing timestamps. Otherwise, valid "older" provider points could
    // be rejected.
    //
    // Future plan:
    // - Introduce providerTimestamp alongside stored timestamp.
    // - Replace this check with a heuristic:
    //     (a) providerTimestamp > last.providerTimestamp OR
    //     (b) significant distance moved OR
    //     (c) better accuracy
    // This will prevent duplicates without dropping legitimate points.
    //
    // For now we keep this method in place, since it does no harm and
    // preserves validation structure.
    bool answer = true;
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      DateTime candidateTime = point.properties.timestamp;
      DateTime lastTime = lastPoint.timestamp;

      answer = candidateTime.isAfter(lastTime);
    }

    return answer;
  }

  Future<bool> _isPointDistanceGreaterThanPreference(LocalPoint point) async {
    bool answer = true;
    int minimumDistance =
    await _trackerPreferencesService.getMinimumPointDistanceSetting();
    Option<LastPoint> lastPointResult = await getLastPoint();

    if (lastPointResult case Some(value: LastPoint lastPoint)) {
      double currentPointLongitude = point.geometry.longitude;
      double currentPointLatitude = point.geometry.latitude;

      LatLng lastPointCoordinates =
      LatLng(lastPoint.latitude, lastPoint.longitude);
      LatLng currentPointCoordinates =
      LatLng(currentPointLatitude, currentPointLongitude);

      PointPair pair = PointPair(lastPointCoordinates, currentPointCoordinates);
      double distance = pair.calculateDistance();

      answer = distance >= minimumDistance;
    }

    return answer;
  }

  Future<bool> _isPointAccurateEnough(LocalPoint candidate) async {
    bool answer = false;
    LocationAccuracy requiredAccuracy =
    await _trackerPreferencesService.getLocationAccuracySetting();

    double requiredAccuracyMeters = _getAccuracyThreshold(requiredAccuracy);

    answer = candidate.properties.horizontalAccuracy < requiredAccuracyMeters;

    return answer;
  }

  double _getAccuracyThreshold(LocationAccuracy accuracy) {
    if (Platform.isIOS) {
      switch (accuracy) {
        case LocationAccuracy.lowest:
          return 3000; // iOS Lowest accuracy
        case LocationAccuracy.low:
          return 1000; // iOS Low accuracy
        case LocationAccuracy.medium:
          return 100; // iOS Medium accuracy
        case LocationAccuracy.high:
          return 10; // iOS High accuracy
        case LocationAccuracy.bestForNavigation:
          return 0; // iOS Navigation-specific accuracy
        case LocationAccuracy.reduced:
          return 3000; // iOS Reduced accuracy
        default:
          throw ArgumentError("Unsupported LocationAccuracy value: $accuracy");
      }
    } else if (Platform.isAndroid) {
      switch (accuracy) {
        case LocationAccuracy.lowest:
          return 500; // Android Passive accuracy
        case LocationAccuracy.low:
          return 500; // Android Low power accuracy
        case LocationAccuracy.medium:
          return 500; // Android Balanced power accuracy
        case LocationAccuracy.high:
          return 100; // Android High accuracy
        case LocationAccuracy.best:
          return 100; // Android matches High accuracy
        default:
          throw ArgumentError("Unsupported LocationAccuracy value: $accuracy");
      }
    } else {
      // Default for unsupported platforms
      throw UnsupportedError(
          "Unsupported platform for LocationAccuracy handling.");
    }
  }

}