
import 'package:dawarich/features/tracking/application/repositories/location_provider_interface.dart';
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option.dart';
import 'package:option_result/result.dart';

final class LocationProvider implements ILocationProvider {

  @override
  Future<Result<Position, String>> getPosition(
      LocationAccuracy locationAccuracy) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: locationAccuracy,
          distanceFilter: 0,
          timeLimit: const Duration(seconds: 10),
        ),
      );

      return Ok(position);
    } catch (error) {
      return Err("Failed to retrieve GPS location: $error");
    }
  }

  @override
  Future<Option<Position>> getCachedPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: true);

      return position != null ? Some(position) : const None();
    } catch (error) {
      return const None();
    }
  }


}