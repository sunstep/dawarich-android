import 'package:dawarich/core/database/repositories/local_point_repository_interfaces.dart';
import 'package:dawarich/features/tracking/application/converters/point/last_point_converter.dart';
import 'package:dawarich/features/tracking/data/data_transfer_objects/point/last_point_dto.dart';
import 'package:dawarich/features/tracking/domain/models/last_point.dart';
import 'package:option_result/option.dart';

final class GetLastPointUseCase {

  final IPointLocalRepository _localPointRepository;

  GetLastPointUseCase(this._localPointRepository);

  Future<Option<LastPoint>> call(int userId) async {
    Option<LastPoint> pointResult =
    await _localPointRepository.getLastPoint(userId);

    if (pointResult case Some(value: final LastPointDto lastPointDto)) {
      final LastPoint lastPoint = lastPointDto.toDomain();
      return Some(lastPoint);
    }

    return const None();
  }
}