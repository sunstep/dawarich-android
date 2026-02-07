
import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';
import 'package:option_result/result.dart';

final class LocationProvider implements ILocationProvider {

  @override
  Future<Result<LocationFix, String>> getCurrent(LocationAccuracy accuracy) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: 0,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      return Ok(_toFix(position));
    } catch (error) {
      return Err("Failed to retrieve GPS location: $error");
    }
  }

  @override
  Future<Option<LocationFix>> getLastKnown() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );

      if (position == null) {
        return const None();
      }

      return Some(_toFix(position));
    } catch (_) {
      return const None();
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  LocationFix _toFix(Position p) {
    return LocationFix(
      latitude: p.latitude,
      longitude: p.longitude,
      timestampUtc: p.timestamp,
      hAccuracyMeters: p.accuracy,

      altitudeMeters: p.altitude,
      speedMps: p.speed,
      headingDegrees: p.heading,

      altitudeAccuracyMeters: p.altitudeAccuracy,
      speedAccuracyMps: p.speedAccuracy,
      headingAccuracyDegrees: p.headingAccuracy,

      provider: p.isMocked ? 'mock' : null,
      isMocked: p.isMocked,
    );
  }

}