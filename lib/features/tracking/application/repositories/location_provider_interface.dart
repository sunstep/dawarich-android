
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:geolocator/geolocator.dart' show LocationAccuracy;
import 'package:option_result/option_result.dart';

abstract class ILocationProvider {
  /// Gets the current location with the specified accuracy.
  Future<Result<LocationFix, String>> getCurrent(LocationAccuracy accuracy);

  /// Gets the last known/cached location if available.
  Future<Option<LocationFix>> getLastKnown();

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();
}