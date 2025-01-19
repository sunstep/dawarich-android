
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

class GpsDataSource {

  Future<Result<Position, String>> getPosition() async {

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
          timeLimit: null,
        ),
      );

      return Ok(position);
    } catch (error) {

      return Err("Failed to retrieve GPS location: $error");
    }

  }

  Future<Option<Position>> getCachedPosition() async {

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);

      return position != null ? Some(position) : const None();
    } catch (error) {
      return const None();
    }

  }
}