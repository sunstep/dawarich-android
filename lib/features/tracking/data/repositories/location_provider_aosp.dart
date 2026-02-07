
import 'dart:io';

import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:dawarich/features/tracking/domain/enum/location_precision.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:dawarich/features/tracking/domain/models/location_request.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';
import 'package:option_result/result.dart';

/// AOSP-only location provider that bypasses Google Play Services.
/// Used for F-Droid builds and other FOSS distributions.
final class AospLocationProvider implements ILocationProvider {

  @override
  Future<Result<LocationFix, String>> getCurrent(LocationRequest request) async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: _toLocationSettings(request),
      );

      return Ok(_toFix(position));
    } catch (error) {
      return Err("Failed to retrieve GPS location: $error");
    }
  }

  @override
  Future<Option<LocationFix>> getLastKnown() async {
    try {
      final Position? position = await Geolocator.getLastKnownPosition();

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

  LocationSettings _toLocationSettings(LocationRequest request) {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: _toGeolocatorAccuracy(request.precision),
        distanceFilter: request.distanceFilterMeters ?? 0,
        timeLimit: request.timeLimit,
        forceLocationManager: true,
      );
    }

    // iOS and other platforms use standard settings
    return LocationSettings(
      accuracy: _toGeolocatorAccuracy(request.precision),
      distanceFilter: request.distanceFilterMeters ?? 0,
      timeLimit: request.timeLimit,
    );
  }

  LocationAccuracy _toGeolocatorAccuracy(LocationPrecision precision) {
    switch (precision) {
      case LocationPrecision.best:
        return LocationAccuracy.best;
      case LocationPrecision.high:
        return LocationAccuracy.high;
      case LocationPrecision.balanced:
        return LocationAccuracy.medium;
      case LocationPrecision.lowPower:
        return LocationAccuracy.low;
    }
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

      provider: p.isMocked ? 'mock' : 'aosp',
      isMocked: p.isMocked,
    );
  }

}



