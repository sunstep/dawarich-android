
import 'package:geolocator/geolocator.dart';
import 'package:option_result/option_result.dart';

abstract class ILocationProvider {

  Future<Result<Position, String>> getPosition(
      LocationAccuracy locationAccuracy);
  Future<Option<Position>> getCachedPosition();
}