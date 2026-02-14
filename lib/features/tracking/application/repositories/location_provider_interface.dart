
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:dawarich/features/tracking/domain/models/location_request.dart';
import 'package:option_result/option_result.dart';

abstract class ILocationProvider {
  /// Gets the current location with the specified accuracy.
  Future<Result<LocationFix, String>> getCurrent(LocationRequest request);

  /// Gets the last known/cached location if available.
  Future<Option<LocationFix>> getLastKnown();

  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Returns a stream of location fixes based on the request settings.
  /// The stream emits whenever the device receives a new location update
  /// from the OS.
  Stream<LocationFix> getLocationStream(LocationRequest request);
}