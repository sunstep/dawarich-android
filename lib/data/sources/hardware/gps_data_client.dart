import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

final class GpsDataClient {

  Future<Result<Position, String>> getPosition(LocationAccuracy locationAccuracy) async {

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

  Future<Option<Position>> getCachedPosition() async {

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);

      return position != null ? Some(position) : const None();
    } catch (error) {
      return const None();
    }

  }

  Stream<Result<Position, String>> getPositionStream({
    required LocationAccuracy accuracy,
    required int distanceFilter,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    ).transform(
      StreamTransformer<Position, Result<Position, String>>.fromHandlers(
        handleData: (position, sink) {
          sink.add(Ok<Position, String>(position));
        },
        handleError: (error, stackTrace, sink) {
          sink.add(Err(error.toString()));
        },
      ),
    );
  }

}