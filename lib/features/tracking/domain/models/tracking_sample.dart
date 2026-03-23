
import 'package:dawarich/core/domain/models/point/local/local_point.dart';
import 'package:dawarich/features/tracking/domain/models/location_fix.dart';
import 'package:option_result/result.dart';

final class TrackingSample {

  final LocationFix fix;
  final Result<LocalPoint, String>? pointResult;

  const TrackingSample({
    required this.fix,
    required this.pointResult,
  });

}