

import 'package:dawarich/core/domain/models/point/api/slim_api_point.dart';
import 'package:dawarich/core/network/repositories/api_point_repository_interfaces.dart';
import 'package:dawarich/features/timeline/application/converters/slim_point_converter.dart';
import 'package:dawarich/features/timeline/application/helpers/timeline_points_processor.dart';
import 'package:dawarich/features/timeline/data/data_transfer_objects/slim_api_point_dto.dart';
import 'package:dawarich/features/timeline/domain/models/day_map_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:option_result/option.dart';

final class LoadTimelineUseCase {

  final IApiPointRepository _apiPointRepository;
  final TimelinePointsProcessor _pointsProcessor;
  LoadTimelineUseCase(this._apiPointRepository, this._pointsProcessor);

  Future<DayMapData> call(DateTime date) async {

    final start = DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime.utc(date.year, date.month, date.day, 23, 59, 59);

    Option<List<SlimApiPointDTO>> result =
    await _apiPointRepository.getSlimPoints(
        startDate: start,
        endDate:  end,
        perPage:  1750
    );

    if (result case Some(value: final List<SlimApiPointDTO> pointDtos)) {
      List<SlimApiPoint> slimPoints = pointDtos
          .map((dto) => dto.toDomain())
          .toList();
      final lastDayTimestamp = slimPoints.lastOrNull?.timestamp;
      final List<LatLng> dayPoints = _pointsProcessor.processPoints(slimPoints);

      return DayMapData(
        points: dayPoints,
        lastTimestampMs: lastDayTimestamp,
      );
    }

    return DayMapData();
  }

}